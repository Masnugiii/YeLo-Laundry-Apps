#!/usr/bin/env python3
"""Sprint 11 manual UAT — API + RBAC + cross-platform verification."""
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
CUSTOMER_A = "081910090910"
CUSTOMER_B = "081910090902"

STAFF_PHONES = {
    "OWNER": "081234567890",
    "CASHIER": "081234567891",
    "OPERATOR": "081234567892",
    "MANAGER": "081234567893",
    "BINATU": "081234567894",
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
    for log_path in LOG_PATHS[:5]:
        if not log_path.exists():
            continue
        matches = re.findall(pattern, log_path.read_text(errors="ignore")[-80000:])
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
    time.sleep(0.5)
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
                "fullName": f"UAT Customer {phone[-4:]}",
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


def expect_forbidden(code: int, label: str) -> None:
    if code in (403, 401):
        R.ok(label)
    else:
        R.fail(label, f"expected 403/401 got HTTP {code}")


def main() -> int:
    code, _ = request("GET", HEALTH)
    if code != 200:
        R.fail("Health", f"HTTP {code}")
        print_report()
        return 1
    R.ok("Health + DB")

    tokens = {role: staff_login(phone) for role, phone in STAFF_PHONES.items()}
    for role, token in tokens.items():
        if token:
            R.ok(f"Staff login {role}")
        else:
            R.fail(f"Staff login {role}")

    owner = tokens.get("OWNER")
    cashier = tokens.get("CASHIER")
    operator = tokens.get("OPERATOR")
    manager = tokens.get("MANAGER")
    binatu = tokens.get("BINATU")

    customer_a = customer_auth(CUSTOMER_A)
    customer_b = customer_auth(CUSTOMER_B)
    if customer_a:
        R.ok("Customer A auth")
    else:
        R.fail("Customer A auth")
        print_report()
        return 1
    if customer_b:
        R.ok("Customer B auth")
    else:
        R.fail("Customer B auth")

    # RBAC negative tests
    if cashier:
        code, _ = request("PATCH", f"{BASE}/settings/receipt", token=cashier, body={"footerText": "deny"})
        expect_forbidden(code, "RBAC CASHIER deny PATCH settings/receipt")
        code, _ = request("POST", f"{BASE}/employees", token=cashier, body={"fullName": "X", "phone": "081999999991"})
        expect_forbidden(code, "RBAC CASHIER deny POST employees")

    if binatu:
        code, _ = request("PATCH", f"{BASE}/settings/company", token=binatu, body={"companyName": "deny"})
        expect_forbidden(code, "RBAC BINATU deny PATCH settings/company")
        code, _ = request("POST", f"{BASE}/wallet/adjustment", token=binatu, body={"customerId": "x", "amount": 1, "reason": "x"})
        expect_forbidden(code, "RBAC BINATU deny wallet adjustment")

    if operator:
        code, _ = request("PATCH", f"{BASE}/numbering/ORDER", token=operator, body={"prefix": "XX"})
        expect_forbidden(code, "RBAC OPERATOR deny PATCH numbering")

    if manager:
        code, _ = request("GET", f"{BASE}/settings/company", token=manager)
        if code == 200:
            R.ok("RBAC MANAGER allow GET settings/company")
        else:
            R.fail("RBAC MANAGER GET settings/company", f"HTTP {code}")
        code, _ = request("PATCH", f"{BASE}/settings/receipt", token=manager, body={"footerText": "deny"})
        expect_forbidden(code, "RBAC MANAGER deny PATCH settings/receipt")

    # Customer profile + address
    code, profile = request("GET", f"{BASE}/auth/profile", token=customer_a)
    profile_data = extract_data(profile) if isinstance(profile, dict) else {}
    customer_id = profile_data.get("id", "")
    if code == 200 and customer_id:
        R.ok("Customer GET profile")
    else:
        R.fail("Customer GET profile", f"HTTP {code}")

    code, addr = request(
        "POST",
        f"{BASE}/customers/{customer_id}/addresses",
        token=customer_a,
        body={
            "label": "UAT Home",
            "recipientName": "UAT Customer",
            "phone": CUSTOMER_A,
            "address": "Jl UAT No 1",
            "province": "Banten",
            "city": "Tangerang Selatan",
            "district": "Serpong",
            "postalCode": "15414",
            "latitude": -6.2,
            "longitude": 106.7,
            "isDefault": True,
        },
    )
    addr_id = (extract_data(addr) or {}).get("id") if isinstance(addr, dict) else None
    if code in (200, 201) and addr_id:
        R.ok("Customer create address")
        code2, _ = request("GET", f"{BASE}/customers/{customer_id}/addresses", token=customer_a)
        if code2 == 200:
            R.ok("Customer list addresses")
    else:
        R.fail("Customer create address", f"HTTP {code} {addr}")

    # Notifications
    code, notif = request("GET", f"{BASE}/notifications", token=customer_a)
    if code == 200:
        R.ok("Customer GET notifications")
        items = extract_items(notif)
        R.notes["notification_count"] = len(items)
    else:
        R.fail("Customer GET notifications", f"HTTP {code}")

    code, unread = request("GET", f"{BASE}/notifications/unread-count", token=customer_a)
    if code == 200:
        R.ok("Customer GET unread-count")
    else:
        R.fail("Customer GET unread-count", f"HTTP {code}")

    # Wallet + rewards baseline
    _, rewards_before = request("GET", f"{BASE}/customer-app/rewards", token=customer_a)
    points_before = (extract_data(rewards_before) or {}).get("currentPoints", 0)
    wallet_before = (extract_data(rewards_before) or {}).get("walletBalance", 0)

    # Create UAT order
    _, services = request("GET", f"{BASE}/customer-app/services", token=customer_a)
    _, perfumes = request("GET", f"{BASE}/customer-app/perfumes", token=customer_a)
    service_items = extract_items(services)
    perfume_items = extract_items(perfumes)
    if not service_items:
        R.fail("Order create", "no services")
        print_report()
        return 1

    order_body: dict[str, Any] = {
        "items": [{"serviceId": service_items[0]["id"], "quantity": 2}],
        "pickupRequired": False,
        "deliveryRequired": False,
        "paymentMethod": "YELO_WALLET",
    }
    if perfume_items:
        order_body["perfumeId"] = perfume_items[0]["id"]

    code, order_resp = request("POST", f"{BASE}/customer-app/orders", token=customer_a, body=order_body)
    order = extract_data(order_resp) if isinstance(order_resp, dict) else {}
    order_id = order.get("id", "")
    order_number = order.get("orderNumber", "")
    if code in (200, 201) and order_id:
        R.ok("Customer create order")
    else:
        R.fail("Customer create order", f"HTTP {code}")
        print_report()
        return 1

    # Numbering uniqueness (3 orders)
    order_numbers = [order_number]
    for i in range(2):
        code, resp = request("POST", f"{BASE}/customer-app/orders", token=customer_a, body=order_body)
        if code in (200, 201):
            o = extract_data(resp) or {}
            order_numbers.append(o.get("orderNumber", ""))
    if len(order_numbers) == 3 and len(set(order_numbers)) == 3:
        R.ok("Numbering uniqueness (3 orders)")
    else:
        R.fail("Numbering uniqueness", str(order_numbers))

    # Pay + lifecycle
    code, _ = request(
        "POST",
        f"{BASE}/customer-app/orders/{order_id}/pay",
        token=customer_a,
        body={"paymentMethod": "YELO_WALLET"},
    )
    if code in (200, 201):
        R.ok("Customer order payment")
    else:
        R.fail("Customer order payment", f"HTTP {code}")

    _, current = request("GET", f"{BASE}/orders/{order_id}", token=owner)
    current_status = (extract_data(current) or {}).get("orderStatus") if isinstance(current, dict) else None
    remaining = LIFECYCLE[LIFECYCLE.index(current_status) + 1 :] if current_status in LIFECYCLE else LIFECYCLE[1:]

    for status in remaining:
        token = owner or cashier
        code, _ = request(
            "PATCH",
            f"{BASE}/orders/{order_id}",
            token=token,
            body={"status": status, "statusNotes": f"Sprint11 -> {status}"},
        )
        if code == 200:
            R.ok(f"Lifecycle -> {status}")
        else:
            R.fail(f"Lifecycle -> {status}", f"HTTP {code}")
            break

    # Cross-platform + timeline/tracking
    if owner:
        _, staff_order = request("GET", f"{BASE}/orders/{order_id}", token=owner)
        _, cust_order = request("GET", f"{BASE}/customer-app/orders/{order_id}", token=customer_a)
        so = extract_data(staff_order) if isinstance(staff_order, dict) else {}
        co = extract_data(cust_order) if isinstance(cust_order, dict) else {}

        if so.get("invoiceNumber") == co.get("orderNumber"):
            R.ok("Cross-platform order number")
        else:
            R.fail("Cross-platform order number", f"{so.get('invoiceNumber')} vs {co.get('orderNumber')}")

        staff_status = so.get("orderStatus")
        cust_status = co.get("status") or co.get("orderStatus")
        if staff_status == cust_status:
            R.ok("Cross-platform order status")
        else:
            R.fail("Cross-platform order status", f"{staff_status} vs {cust_status}")

        for path, label in [
            (f"/customer-app/orders/{order_id}/timeline", "Customer timeline API"),
            (f"/customer-app/orders/{order_id}/laundry-tracking", "Customer laundry tracking API"),
            (f"/customer-app/orders/{order_id}/delivery-tracking", "Customer delivery tracking API"),
        ]:
            code, _ = request("GET", f"{BASE}{path}", token=customer_a)
            if code == 200:
                R.ok(label)
            else:
                R.fail(label, f"HTTP {code}")

        R.notes["uat_order"] = {
            "orderId": order_id,
            "orderNumber": order_number,
            "customerId": co.get("customerId"),
            "subtotal": so.get("subtotal"),
            "tax": so.get("tax"),
            "grandTotal": so.get("grandTotal"),
            "paymentStatus": co.get("paymentStatus"),
            "orderStatus": staff_status,
            "walletBefore": wallet_before,
            "pointsBefore": points_before,
        }

    # Ownership
    if customer_b and order_id:
        code, _ = request("GET", f"{BASE}/customer-app/orders/{order_id}", token=customer_b)
        if code in (403, 404):
            R.ok("Ownership order isolation")
        else:
            R.fail("Ownership order isolation", f"HTTP {code}")

    # CS ticket round-trip
    code, ticket = request(
        "POST",
        f"{BASE}/customer-app/support/tickets",
        token=customer_a,
        body={"category": "PERTANYAAN", "subject": "Sprint11 UAT", "message": "Test message"},
    )
    tid = (extract_data(ticket) or {}).get("id") if isinstance(ticket, dict) else None
    if code in (200, 201) and tid and owner:
        R.ok("CS ticket create")
        code2, _ = request(
            "POST",
            f"{BASE}/customer-service/tickets/{tid}/messages",
            token=owner,
            body={"message": "Staff reply Sprint11"},
        )
        if code2 in (200, 201):
            R.ok("CS staff reply")
            code3, msgs = request("GET", f"{BASE}/customer-app/support/tickets/{tid}", token=customer_a)
            if code3 == 200:
                R.ok("CS customer read ticket")
            else:
                R.fail("CS customer read ticket", f"HTTP {code3}")

    # Admin-equivalent reads (owner token)
    if owner:
        for path in (
            "customers",
            "orders",
            "payments",
            "reports/dashboard",
            "settings/company",
            "settings/receipt",
            "settings/numbering",
            "employees",
            "admin/audit-logs",
            "admin/dashboard",
        ):
            code, _ = request("GET", f"{BASE}/{path}", token=owner)
            if code == 200:
                R.ok(f"Admin API GET /{path}")
            else:
                R.fail(f"Admin API GET /{path}", f"HTTP {code}")

    # Mission claim if available
    _, missions = request("GET", f"{BASE}/customer-app/missions", token=customer_a)
    claimable = next((m for m in extract_items(missions) if m.get("status") != "completed"), None)
    if claimable:
        mid = claimable["id"]
        code, _ = request("POST", f"{BASE}/customer-app/missions/{mid}/claim", token=customer_a)
        if code in (200, 201):
            R.ok("Mission claim")
            code2, _ = request("POST", f"{BASE}/customer-app/missions/{mid}/claim", token=customer_a)
            if code2 in (400, 409, 422):
                R.ok("Mission double-claim rejected")
            else:
                R.fail("Mission double-claim rejected", f"HTTP {code2}")

    R.block("DRIVER role login", "No dedicated DRIVER seed account — MANAGER seed covers driver permissions")
    R.block("Flutter visual manual UAT", "Requires on-device tester — API layer verified")
    R.block("Payment gateway webhook", "External deferred dependency")
    R.block("Production OTP delivery", "External deferred dependency")

    print_report()
    return 0 if not R.failed else 1


def print_report() -> None:
    print("\n=== SPRINT 11 MANUAL UAT (API) ===")
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
