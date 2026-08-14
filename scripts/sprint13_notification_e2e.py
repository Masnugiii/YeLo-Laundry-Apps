#!/usr/bin/env python3
"""Sprint 13 — lifecycle notification E2E + release verification hooks."""
from __future__ import annotations

import json
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

BASE = "http://localhost:3000/api/v1"
STAFF_PASSWORD = "admin123"
CUSTOMER_A = "081910090910"
CUSTOMER_B = "081910090902"
BACKEND_LOG = Path("/tmp/yelo_backend_e2e.log")
ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")
LIFECYCLE_WALKIN = [
    "WAITING_PAYMENT",
    "PAYMENT_CONFIRMED",
    "WAITING_BINATU",
    "IRONING_ACCEPTED",
    "CURRENTLY_IRONING",
    "FINISHED_IRONING",
    "READY_FOR_PICKUP",
    "COMPLETED",
]
LIFECYCLE_DELIVERY = [
    "WAITING_PAYMENT",
    "PAYMENT_CONFIRMED",
    "WAITING_BINATU",
    "IRONING_ACCEPTED",
    "CURRENTLY_IRONING",
    "FINISHED_IRONING",
    "WAITING_DELIVERY",
    "OUT_FOR_DELIVERY",
    "DELIVERED",
    "COMPLETED",
]
EXPECTED_TITLES = {
    "Order Created",
    "Payment Successful",
    "Laundry Started",
    "Laundry Finished",
    "Ready For Pickup",
    "Delivery Started",
    "Delivery Completed",
}


def request(method: str, url: str, *, token: str | None = None, body: dict | None = None):
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=45) as resp:
            raw = resp.read().decode()
            return resp.status, json.loads(raw)
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try:
            return e.code, json.loads(raw)
        except json.JSONDecodeError:
            return e.code, {"raw": raw}


def extract_token(payload):
    if not isinstance(payload, dict):
        return None
    return (payload.get("data") or {}).get("accessToken")


def extract_data(payload):
    if isinstance(payload, dict):
        return payload.get("data", payload)
    return payload


def extract_items(payload):
    data = extract_data(payload)
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        items = data.get("items")
        return items if isinstance(items, list) else []
    return []


def log_sources() -> list[Path]:
    paths: list[Path] = []
    if BACKEND_LOG.exists():
        paths.append(BACKEND_LOG)
    terminal_dir = Path("/Users/ams/.cursor/projects/Users-ams-Desktop-yelo-laundry-erp/terminals")
    if terminal_dir.exists():
        paths.extend(
            sorted(terminal_dir.glob("*.txt"), key=lambda p: p.stat().st_mtime, reverse=True)[:8]
        )
    return paths


def read_log_tail(path: Path, size: int = 200_000) -> str:
    text = path.read_text(errors="ignore")
    return ANSI_RE.sub("", text[-size:])


def extract_otp(phone_tail: str) -> str | None:
    pattern = rf"OTP reference for .*{phone_tail}.*: (\d{{6}})"
    for log_path in log_sources():
        matches = re.findall(pattern, read_log_tail(log_path))
        if matches:
            return matches[-1]
    return None


def pending_otp_request_id(phone: str) -> str | None:
    import subprocess

    script = f"""
const {{ PrismaClient, OtpStatus }} = require('@prisma/client');
const p = new PrismaClient();
(async () => {{
  const otp = await p.otpCode.findFirst({{
    where: {{
      phone: {json.dumps(phone)},
      status: OtpStatus.pending,
      expiresAt: {{ gt: new Date() }},
      deletedAt: null,
    }},
    orderBy: {{ createdAt: 'desc' }},
    select: {{ id: true }},
  }});
  if (otp) process.stdout.write(otp.id);
  await p.$disconnect();
}})();
"""
    try:
        result = subprocess.run(
            ["node", "-e", script],
            cwd=str(Path(__file__).resolve().parents[1]),
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
        )
        otp_id = (result.stdout or "").strip()
        return otp_id or None
    except (OSError, subprocess.SubprocessError):
        return None


def customer_auth(phone: str) -> tuple[str | None, str]:
    code, send = request("POST", f"{BASE}/auth/otp/send", body={"phone": phone, "purpose": "login"})
    if code not in (200, 201, 429):
        return None, f"otp/send HTTP {code}"
    send_data = extract_data(send) or {}
    otp_id = send_data.get("otpRequestId", "")
    if code == 429 and not otp_id:
        otp_id = pending_otp_request_id(phone) or ""
    if not otp_id:
        return None, "missing otpRequestId"
    time.sleep(0.8)
    otp = extract_otp(phone[-4:])
    if not otp:
        return None, f"OTP not found in logs for ***{phone[-4:]}"
    code, auth = request(
        "POST",
        f"{BASE}/auth/otp/verify",
        body={"phone": phone, "otpRequestId": otp_id, "otpCode": otp},
    )
    token = extract_token(auth) if code in (200, 201) else None
    if not token:
        return None, f"otp/verify HTTP {code}"
    return token, "ok"


def run_lifecycle(
    owner: str,
    customer_token: str,
    order_id: str,
    lifecycle: list[str],
    *,
    ok,
    fail,
    dedup_status: str | None = None,
) -> None:
    _, current = request("GET", f"{BASE}/orders/{order_id}", token=owner)
    current_status = (extract_data(current) or {}).get("orderStatus")
    remaining = lifecycle[lifecycle.index(current_status) + 1 :] if current_status in lifecycle else lifecycle[1:]

    for status in remaining:
        code, _ = request(
            "PATCH",
            f"{BASE}/orders/{order_id}",
            token=owner,
            body={"status": status, "statusNotes": f"S13.2 -> {status}"},
        )
        if code == 200:
            ok(f"lifecycle -> {status}")
        else:
            fail(f"lifecycle -> {status}", f"HTTP {code}")
            return

        if dedup_status and status == dedup_status:
            before_dup = count_order_notifications(customer_token, order_id)
            dup_code, _ = request(
                "PATCH",
                f"{BASE}/orders/{order_id}",
                token=owner,
                body={"status": status, "statusNotes": f"S13.2 duplicate {status}"},
            )
            after_dup = count_order_notifications(customer_token, order_id)
            if dup_code == 400:
                ok(f"duplicate status blocked ({status})")
            else:
                fail(f"duplicate status ({status})", f"HTTP {dup_code}")
            if after_dup == before_dup:
                ok(f"dedup count unchanged after duplicate {status}")
            else:
                fail("dedup count", f"before={before_dup} after={after_dup}")


def count_order_notifications(token: str, order_id: str) -> int:
    _, notif = request("GET", f"{BASE}/notifications?limit=100", token=token)
    items = extract_items(notif)
    return len([i for i in items if i.get("orderId") == order_id])


def create_and_pay_order(customer: str, *, delivery_required: bool) -> tuple[str, str, str]:
    _, services = request("GET", f"{BASE}/customer-app/services", token=customer)
    service_items = extract_items(services)
    if not service_items:
        raise RuntimeError("no services")
    code, order_resp = request(
        "POST",
        f"{BASE}/customer-app/orders",
        token=customer,
        body={
            "items": [{"serviceId": service_items[0]["id"], "quantity": 1}],
            "pickupRequired": False,
            "deliveryRequired": delivery_required,
            "paymentMethod": "YELO_WALLET",
        },
    )
    order = extract_data(order_resp) or {}
    order_id = order.get("id", "")
    order_number = order.get("orderNumber", "")
    customer_id = order.get("customerId", "")
    if code not in (200, 201) or not order_id:
        raise RuntimeError(f"create order HTTP {code}")
    code, _ = request(
        "POST",
        f"{BASE}/customer-app/orders/{order_id}/pay",
        token=customer,
        body={"paymentMethod": "YELO_WALLET"},
    )
    if code not in (200, 201):
        raise RuntimeError(f"pay order HTTP {code}")
    return order_id, order_number, customer_id


def main() -> int:
    passed: list[str] = []
    failed: list[str] = []

    def ok(name: str) -> None:
        passed.append(name)

    def fail(name: str, detail: str = "") -> None:
        failed.append(f"{name}: {detail}" if detail else name)

    owner = extract_token(
        request("POST", f"{BASE}/auth/login", body={"phone": "081234567890", "password": STAFF_PASSWORD})[1]
    )
    customer, customer_auth_detail = customer_auth(CUSTOMER_A)
    if not owner:
        print("BLOCKED: owner auth failed")
        return 1
    if not customer:
        print(f"BLOCKED: customer auth failed ({customer_auth_detail})")
        return 1
    ok("owner auth")
    ok("customer A auth")

    try:
        walkin_id, walkin_number, walkin_customer_id = create_and_pay_order(customer, delivery_required=False)
        ok("walk-in order created")
        ok("walk-in order paid")
    except RuntimeError as exc:
        fail("walk-in order setup", str(exc))
        print_report(passed, failed)
        return 1

    try:
        delivery_id, delivery_number, _ = create_and_pay_order(customer, delivery_required=True)
        ok("delivery order created")
        ok("delivery order paid")
    except RuntimeError as exc:
        fail("delivery order setup", str(exc))
        print_report(passed, failed)
        return 1

    _, before = request("GET", f"{BASE}/notifications?limit=100", token=customer)
    before_count = len(extract_items(before))

    run_lifecycle(
        owner,
        customer,
        walkin_id,
        LIFECYCLE_WALKIN,
        ok=ok,
        fail=fail,
        dedup_status="IRONING_ACCEPTED",
    )

    dup_code, _ = request(
        "PATCH",
        f"{BASE}/orders/{walkin_id}",
        token=owner,
        body={"status": "COMPLETED"},
    )
    if dup_code == 400:
        ok("terminal duplicate status blocked")
    else:
        fail("terminal duplicate status", f"HTTP {dup_code}")

    run_lifecycle(owner, customer, delivery_id, LIFECYCLE_DELIVERY, ok=ok, fail=fail)

    _, notif = request("GET", f"{BASE}/notifications?limit=100", token=customer)
    items = extract_items(notif)
    order_numbers = {walkin_number, delivery_number}
    order_items = [i for i in items if i.get("orderNumber") in order_numbers]
    titles = {i.get("title") for i in order_items}

    if len(items) > before_count:
        ok("notification count increased after lifecycle")
    else:
        fail("notification count", f"before={before_count} after={len(items)}")

    for title in EXPECTED_TITLES:
        if title in titles:
            ok(f"notification title: {title}")
        else:
            fail("notification title", f"missing {title}; got {sorted(titles)}")

    walkin_items = [i for i in order_items if i.get("orderNumber") == walkin_number]
    delivery_items = [i for i in order_items if i.get("orderNumber") == delivery_number]

    if not order_items:
        fail("notification list", "no notifications for created orders")
    else:
        ok("notification list has order items")
    if order_items:
        for item in order_items:
            if not item.get("id"):
                fail("notification content", "missing id")
                break
            if item.get("orderId") not in {walkin_id, delivery_id}:
                fail("notification content", f"wrong orderId {item.get('orderId')}")
                break
            if not item.get("title") or not item.get("message") or not item.get("createdAt"):
                fail("notification content", "missing title/message/createdAt")
                break
            if "isRead" not in item:
                fail("notification content", "missing isRead")
                break
        else:
            ok("notification content fields")

    if order_items and walkin_customer_id and all(
        i.get("recipientCustomerId") in (None, walkin_customer_id) for i in order_items
    ):
        ok("notification customer ownership on list")
    elif order_items:
        fail("notification customer ownership", f"expected {walkin_customer_id}")

    _, unread = request("GET", f"{BASE}/notifications/unread-count", token=customer)
    unread_count = (extract_data(unread) or {}).get("count")
    if isinstance(unread_count, int) and unread_count > 0:
        ok("unread count")
    else:
        fail("unread count", f"count={unread_count}")

    if order_items:
        nid = order_items[0]["id"]
        code, detail = request("GET", f"{BASE}/notifications/{nid}", token=customer)
        if code == 200:
            ok("notification detail")
            detail_data = extract_data(detail) or {}
            if detail_data.get("orderId") in {walkin_id, delivery_id}:
                ok("notification detail order reference")
            else:
                fail("notification detail order reference", str(detail_data.get("orderId")))
        code, _ = request("POST", f"{BASE}/notifications/{nid}/read", token=customer)
        if code in (200, 201):
            ok("mark notification read")

    customer_b, customer_b_detail = customer_auth(CUSTOMER_B)
    if not customer_b:
        fail("customer B auth", customer_b_detail)
    elif order_items:
        code, _ = request("GET", f"{BASE}/notifications/{order_items[0]['id']}", token=customer_b)
        if code in (403, 404):
            ok("notification ownership isolation")
        else:
            fail("notification ownership", f"HTTP {code}")

    print_report(
        passed,
        failed,
        walkin_order=walkin_number,
        delivery_order=delivery_number,
        titles=sorted(titles),
    )
    return 0 if not failed else 1


def print_report(passed, failed, **notes):
    print("SPRINT 13 NOTIFICATION E2E")
    print(f"PASS: {len(passed)} FAIL: {len(failed)}")
    for item in passed:
        print(f"  OK  {item}")
    for item in failed:
        print(f"  FAIL {item}")
    for k, v in notes.items():
        print(f"{k}: {v}")


if __name__ == "__main__":
    sys.exit(main())
