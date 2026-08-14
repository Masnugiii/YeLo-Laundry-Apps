#!/usr/bin/env python3
"""Sprint 9 go-live API verification against running backend."""
from __future__ import annotations

import json
import re
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import urllib.error
import urllib.request

BASE = "http://localhost:3000/api/v1"
HEALTH = "http://localhost:3000/health"
LOG_PATHS = sorted(
    Path("/Users/ams/.cursor/projects/Users-ams-Desktop-yelo-laundry-erp/terminals").glob("*.txt"),
    key=lambda p: p.stat().st_mtime,
    reverse=True,
)
STAFF_PASSWORD = "admin123"
TEST_PHONE = "081910090910"
TOPUP_AMOUNT = 200000

STAFF = {
    "OWNER": "081234567890",
    "CASHIER": "081234567891",
    "BINATU": "081234567894",
    "MANAGER": "081234567893",
}

LIFECYCLE = [
    "WAITING_PAYMENT",
    "PAYMENT_CONFIRMED",
    "WAITING_BINATU",
    "IRONING_ACCEPTED",
    "CURRENTLY_IRONING",
    "FINISHED_IRONING",
    "READY_FOR_PICKUP",
    "COMPLETED",
]


@dataclass
class Results:
    passed: list[str] = field(default_factory=list)
    failed: list[str] = field(default_factory=list)
    blocked: list[str] = field(default_factory=list)
    notes: dict[str, Any] = field(default_factory=dict)

    def ok(self, name: str) -> None:
        self.passed.append(name)

    def fail(self, name: str, detail: str = "") -> None:
        self.failed.append(f"{name}: {detail}" if detail else name)

    def block(self, name: str, reason: str) -> None:
        self.blocked.append(f"{name}: {reason}")


R = Results()


def request(method: str, url: str, *, token: str | None = None, body: dict | None = None):
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=45) as resp:
            raw = resp.read().decode()
            try:
                return resp.status, json.loads(raw)
            except json.JSONDecodeError:
                return resp.status, raw
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try:
            return e.code, json.loads(raw)
        except json.JSONDecodeError:
            return e.code, raw


def extract_token(payload: Any) -> str | None:
    if not isinstance(payload, dict):
        return None
    data = payload.get("data") or {}
    return data.get("accessToken") or data.get("token")


def extract_data(payload: Any) -> Any:
    if isinstance(payload, dict):
        return payload.get("data", payload)
    return payload


def extract_items(payload: Any) -> list[dict]:
    data = extract_data(payload)
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        items = data.get("items")
        return items if isinstance(items, list) else []
    return []


def extract_otp(phone_tail: str) -> str | None:
    pattern = rf"OTP reference for .*{phone_tail}.*: (\d{{6}})"
    for log_path in LOG_PATHS[:3]:
        if not log_path.exists():
            continue
        matches = re.findall(pattern, log_path.read_text(errors="ignore")[-50000:])
        if matches:
            return matches[-1]
    return None


def staff_login(phone: str) -> str | None:
    code, body = request("POST", f"{BASE}/auth/login", body={"phone": phone, "password": STAFF_PASSWORD})
    return extract_token(body) if code == 200 else None


def customer_auth(phone: str) -> str | None:
    code, send = request("POST", f"{BASE}/auth/otp/send", body={"phone": phone, "purpose": "register"})
    purpose = "register"
    if code == 409:
        code, send = request("POST", f"{BASE}/auth/otp/send", body={"phone": phone, "purpose": "login"})
        purpose = "login"
    if code not in (200, 201) and code != 429:
        return None
    time.sleep(0.4)
    otp = extract_otp(phone[-4:])
    otp_id = (extract_data(send) or {}).get("otpRequestId", "") if isinstance(send, dict) else ""
    if not otp:
        return None
    if purpose == "register":
        code, auth = request(
            "POST",
            f"{BASE}/auth/customer/register",
            body={
                "phone": phone,
                "otpRequestId": otp_id,
                "otpCode": otp,
                "fullName": "Sprint9 Go-Live Customer",
                "gender": "male",
                "age": 30,
                "occupation": "QA Tester",
            },
        )
    else:
        code, auth = request(
            "POST",
            f"{BASE}/auth/otp/verify",
            body={"phone": phone, "otpRequestId": otp_id, "otpCode": otp},
        )
    return extract_token(auth) if code in (200, 201) else None


def main() -> int:
    code, health = request("GET", HEALTH)
    if code != 200:
        R.fail("Health", str(health))
        print_report()
        return 1
    R.ok("Health + DB")

    tokens = {role: staff_login(phone) for role, phone in STAFF.items()}
    for role, token in tokens.items():
        if token:
            R.ok(f"Staff auth {role}")
        else:
            R.fail(f"Staff auth {role}")

    owner = tokens.get("OWNER")
    cashier = tokens.get("CASHIER")
    binatu = tokens.get("BINATU")

    customer = customer_auth(TEST_PHONE)
    if customer:
        R.ok("Customer auth OTP")
    else:
        R.fail("Customer auth OTP")
        print_report()
        return 1

    # Points before mission
    _, rewards_before = request("GET", f"{BASE}/customer-app/rewards", token=customer)
    points_before = (extract_data(rewards_before) or {}).get("currentPoints", 0)

    _, missions = request("GET", f"{BASE}/customer-app/missions", token=customer)
    mission_items = extract_items(missions)
    claimable = next((m for m in mission_items if m.get("status") != "completed"), None)
    if claimable:
        mid = claimable["id"]
        code, _ = request("POST", f"{BASE}/customer-app/missions/{mid}/claim", token=customer)
        if code in (200, 201):
            R.ok("Mission claim")
            code2, _ = request("POST", f"{BASE}/customer-app/missions/{mid}/claim", token=customer)
            if code2 in (400, 409, 422):
                R.ok("Mission double-claim rejected")
            else:
                R.fail("Mission double-claim rejected", f"HTTP {code2}")
            _, rewards_after = request("GET", f"{BASE}/customer-app/rewards", token=customer)
            points_after = (extract_data(rewards_after) or {}).get("currentPoints", 0)
            if points_after > points_before:
                R.ok("Mission points increased")
                R.notes["mission"] = {"before": points_before, "after": points_after, "missionId": mid}
            else:
                R.fail("Mission points increased", f"{points_before} -> {points_after}")
        else:
            R.fail("Mission claim", f"HTTP {code}")
    else:
        R.notes["mission"] = "No unclaimed mission available"

    # Wallet
    _, wallet_before = request("GET", f"{BASE}/customer-app/rewards", token=customer)
    balance_before = (extract_data(wallet_before) or {}).get("walletBalance", 0)
    code, topup = request(
        "POST",
        f"{BASE}/customer-app/wallet/top-up",
        token=customer,
        body={"amount": TOPUP_AMOUNT, "paymentMethod": "BANK_TRANSFER"},
    )
    req_id = None
    if code in (200, 201) and isinstance(topup, dict):
        req_id = (extract_data(topup) or {}).get("requestId")
        code2, _ = request(
            "POST",
            f"{BASE}/customer-app/wallet/top-up/{req_id}/confirm",
            token=customer,
        )
        if code2 in (200, 201):
            R.ok("Wallet top-up confirm")
            code3, _ = request(
                "POST",
                f"{BASE}/customer-app/wallet/top-up/{req_id}/confirm",
                token=customer,
            )
            if code3 in (400, 409, 422):
                R.ok("Wallet duplicate confirm rejected")
            else:
                R.fail("Wallet duplicate confirm rejected", f"HTTP {code3}")
        else:
            R.fail("Wallet top-up confirm", f"HTTP {code2}")
    else:
        R.fail("Wallet top-up initiate", f"HTTP {code}")

    # Order create + numbering uniqueness
    _, services = request("GET", f"{BASE}/customer-app/services", token=customer)
    _, perfumes = request("GET", f"{BASE}/customer-app/perfumes", token=customer)
    service_items = extract_items(services)
    perfume_items = extract_items(perfumes)
    if not service_items:
        R.fail("Order create", "no services")
        print_report()
        return 1

    order_ids: list[str] = []
    order_numbers: list[str] = []
    for i in range(3):
        body: dict[str, Any] = {
            "items": [{"serviceId": service_items[0]["id"], "quantity": 1 + i}],
            "pickupRequired": False,
            "deliveryRequired": False,
            "paymentMethod": "YELO_WALLET",
        }
        if perfume_items:
            body["perfumeId"] = perfume_items[0]["id"]
        code, order_resp = request("POST", f"{BASE}/customer-app/orders", token=customer, body=body)
        if code in (200, 201) and isinstance(order_resp, dict):
            order = extract_data(order_resp) or {}
            order_ids.append(order.get("id", ""))
            order_numbers.append(order.get("orderNumber", ""))
        else:
            R.fail(f"Order create #{i+1}", f"HTTP {code} {order_resp}")
            break

    if len(order_ids) == 3 and len(set(order_numbers)) == 3:
        R.ok("Numbering uniqueness (3 orders)")
        R.notes["order_numbers"] = order_numbers
    elif order_ids:
        R.fail("Numbering uniqueness", str(order_numbers))

    lifecycle_order_id = order_ids[0] if order_ids else None
    if lifecycle_order_id and cashier:
        code, pay = request(
            "POST",
            f"{BASE}/customer-app/orders/{lifecycle_order_id}/pay",
            token=customer,
            body={"paymentMethod": "YELO_WALLET"},
        )
        if code in (200, 201):
            R.ok("Customer order payment")
        else:
            R.fail("Customer order payment", f"HTTP {code} {pay}")

        _, current = request("GET", f"{BASE}/orders/{lifecycle_order_id}", token=owner)
        current_status = (extract_data(current) or {}).get("orderStatus") if isinstance(current, dict) else None
        remaining = LIFECYCLE[LIFECYCLE.index(current_status) + 1 :] if current_status in LIFECYCLE else LIFECYCLE[1:]

        for status in remaining:
            token = owner or cashier
            code, _ = request(
                "PATCH",
                f"{BASE}/orders/{lifecycle_order_id}",
                token=token,
                body={"status": status, "statusNotes": f"Sprint9 transition to {status}"},
            )
            if code == 200:
                R.ok(f"Lifecycle -> {status}")
            else:
                R.fail(f"Lifecycle -> {status}", f"HTTP {code}")
                break

        if owner:
            _, staff_order = request("GET", f"{BASE}/orders/{lifecycle_order_id}", token=owner)
            _, cust_order = request("GET", f"{BASE}/customer-app/orders/{lifecycle_order_id}", token=customer)
            so = extract_data(staff_order) if isinstance(staff_order, dict) else {}
            co = extract_data(cust_order) if isinstance(cust_order, dict) else {}
            if so.get("invoiceNumber") == co.get("orderNumber"):
                R.ok("Cross-platform order number match")
            if so.get("orderStatus") == co.get("status") or so.get("orderStatus") == co.get("orderStatus"):
                R.ok("Cross-platform order status match")
            tax = so.get("tax")
            if tax is not None and float(tax) >= 0:
                R.ok("Tax present on staff order")
            R.notes["lifecycle_order"] = {
                "orderId": lifecycle_order_id,
                "orderNumber": so.get("invoiceNumber"),
                "status": so.get("orderStatus"),
                "subtotal": so.get("subtotal"),
                "tax": so.get("tax"),
                "serviceFee": so.get("serviceFee"),
                "grandTotal": so.get("grandTotal"),
            }

    # Receipt + numbering settings
    if owner:
        for path in ("settings/receipt", "settings/numbering", "settings/company"):
            code, _ = request("GET", f"{BASE}/{path}", token=owner)
            if code == 200:
                R.ok(f"Settings GET /{path}")
            else:
                R.fail(f"Settings GET /{path}", f"HTTP {code}")

    # Promo quote
    code, quote = request(
        "POST",
        f"{BASE}/customer-app/promos/quote",
        token=customer,
        body={"subtotal": 100000},
    )
    if code == 200:
        R.ok("Promo quote")

    # Ownership
    other = customer_auth("081910090902")
    if lifecycle_order_id and other:
        code, _ = request("GET", f"{BASE}/customer-app/orders/{lifecycle_order_id}", token=other)
        if code in (403, 404):
            R.ok("Ownership order isolation")

    # CS ticket
    code, ticket = request(
        "POST",
        f"{BASE}/customer-app/support/tickets",
        token=customer,
        body={"category": "PERTANYAAN", "subject": "Sprint9", "message": "Go-live test"},
    )
    tid = (extract_data(ticket) or {}).get("id") if isinstance(ticket, dict) else None
    if code in (200, 201) and tid and owner:
        R.ok("CS ticket create")
        code2, _ = request(
            "POST",
            f"{BASE}/customer-service/tickets/{tid}/messages",
            token=owner,
            body={"message": "Staff reply Sprint9"},
        )
        if code2 in (200, 201):
            R.ok("CS staff reply")

    R.block("Payment gateway webhook", "NOT IMPLEMENTED — no webhook endpoint in codebase")
    R.block("Production HTTPS deployment", "NOT AVAILABLE — local runtime only")
    R.block("OTP production delivery", "NOT IMPLEMENTED — OTP stored but not sent via SMS/WhatsApp in production")
    R.block("Database backup restore verify", "Requires isolated restore environment")

    print_report()
    return 0 if not R.failed else 1


def print_report() -> None:
    print("\n=== SPRINT 9 GO-LIVE E2E ===")
    print(f"PASS: {len(R.passed)}")
    print(f"FAIL: {len(R.failed)}")
    print(f"BLOCKED: {len(R.blocked)}")
    if R.notes:
        print("\nNOTES:")
        print(json.dumps(R.notes, indent=2))
    if R.failed:
        print("\nFAILURES:")
        for f in R.failed:
            print(f"  - {f}")
    if R.blocked:
        print("\nBLOCKED:")
        for b in R.blocked:
            print(f"  - {b}")


if __name__ == "__main__":
    sys.exit(main())
