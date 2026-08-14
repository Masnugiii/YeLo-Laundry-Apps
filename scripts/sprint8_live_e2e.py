#!/usr/bin/env python3
"""Sprint 8 live API E2E against running backend."""
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
STAFF_ACCOUNTS = {
    "OWNER": "081234567890",
    "CASHIER": "081234567891",
    "CASHIER_BINATU": "081234567892",
    "MANAGER_DRIVER": "081234567893",
    "BINATU": "081234567894",
}


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


def request(
    method: str,
    url: str,
    *,
    token: str | None = None,
    body: dict | None = None,
) -> tuple[int, dict | list | str]:
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
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


def extract_items(payload: Any) -> list[dict]:
    if isinstance(payload, list):
        return payload
    if not isinstance(payload, dict):
        return []
    data = payload.get("data")
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        items = data.get("items")
        return items if isinstance(items, list) else []
    return []


def extract_token(payload: dict) -> str | None:
    if not isinstance(payload, dict):
        return None
    data = payload.get("data") or {}
    return data.get("accessToken") or data.get("token")


def extract_otp_from_log(phone_tail: str, after_pos: int = 0) -> str | None:
    pattern = rf"OTP reference for .*{phone_tail}.*: (\d{{6}})"
    for log_path in LOG_PATHS[:3]:
        if not log_path.exists():
            continue
        text = log_path.read_text(errors="ignore")
        tail = text[-50000:]
        matches = re.findall(pattern, tail)
        if matches:
            return matches[-1]
    return None


def main() -> int:
    # Health
    code, health = request("GET", HEALTH)
    if code == 200 and isinstance(health, dict) and health.get("data", {}).get("database") == "connected":
        R.ok("Health + DB connected")
    else:
        R.fail("Health", str(health))
        print_report()
        return 1

    tokens: dict[str, str] = {}
    for role, phone in STAFF_ACCOUNTS.items():
        code, body = request("POST", f"{BASE}/auth/login", body={"phone": phone, "password": STAFF_PASSWORD})
        token = extract_token(body) if isinstance(body, dict) else None
        if code == 200 and token:
            tokens[role] = token
            R.ok(f"Staff auth {role}")
        else:
            R.fail(f"Staff auth {role}", f"HTTP {code} {body}")

    owner = tokens.get("OWNER")
    cashier = tokens.get("CASHIER")
    binatu = tokens.get("BINATU")
    manager = tokens.get("MANAGER_DRIVER")

    staff_endpoints = {
        "OWNER": [
            ("GET", "dashboard/summary"),
            ("GET", "orders?page=1&limit=5"),
            ("GET", "customers?page=1&limit=5"),
            ("GET", "perfumes"),
            ("GET", "settings/receipt"),
            ("GET", "settings/numbering"),
            ("GET", "reports/production?period=today"),
            ("GET", "customer-service/summary"),
            ("GET", "admin/dashboard"),
        ],
        "CASHIER": [
            ("GET", "orders?page=1&limit=5"),
            ("GET", "customers?page=1&limit=5"),
            ("GET", "notifications/unread-count"),
        ],
        "BINATU": [
            ("GET", "laundry/dashboard"),
            ("GET", "laundry/queues/ironing"),
            ("GET", "notifications/unread-count"),
        ],
        "MANAGER_DRIVER": [
            ("GET", "reports/dashboard"),
            ("GET", "reports/finance"),
            ("GET", "payroll/dashboard"),
        ],
    }

    for role, endpoints in staff_endpoints.items():
        token = tokens.get(role)
        if not token:
            continue
        for method, path in endpoints:
            code, _ = request(method, f"{BASE}/{path}", token=token)
            if code in (200, 201):
                R.ok(f"{role} {method} /{path}")
            else:
                R.fail(f"{role} {method} /{path}", f"HTTP {code}")

    # RBAC: binatu cannot patch receipt settings
    if binatu:
        code, _ = request(
            "PATCH",
            f"{BASE}/settings/receipt",
            token=binatu,
            body={"showLogo": True},
        )
        if code in (401, 403):
            R.ok("RBAC binatu denied settings/receipt PATCH")
        else:
            R.fail("RBAC binatu denied settings/receipt PATCH", f"HTTP {code}")

    # Customer flow — use seeded test account when available
    customer_token: str | None = None
    customer_id: str | None = None
    test_phone = "081910080801"
    use_seeded_customer = False

    if owner and use_seeded_customer:
        code, customers = request("GET", f"{BASE}/customers?page=1&limit=1", token=owner)
        if code == 200 and isinstance(customers, dict):
            items = (customers.get("data") or {}).get("items") or []
            if items:
                test_phone = items[0].get("phone") or test_phone
                customer_id = items[0].get("id")

    log_pos = 0

    code, otp_send = request(
        "POST",
        f"{BASE}/auth/otp/send",
        body={"phone": test_phone, "purpose": "login"},
    )
    purpose = "login"
    if code == 404:
        log_pos = 0
        code, otp_send = request(
            "POST",
            f"{BASE}/auth/otp/send",
            body={"phone": test_phone, "purpose": "register"},
        )
        purpose = "register"

    if code not in (200, 201):
        if code == 429:
            R.notes["customer_otp"] = "rate limited — using latest dev OTP from log"
        else:
            R.fail("Customer OTP send", f"HTTP {code} {otp_send}")
    if code in (200, 201) or code == 429:
        time.sleep(0.3)
        otp = extract_otp_from_log(test_phone[-4:], log_pos)
        otp_id = ""
        if isinstance(otp_send, dict):
            otp_id = (otp_send.get("data") or {}).get("otpRequestId", "")
        if not otp:
            R.block("Customer OTP verify", "OTP code not found in server log")
        else:
            if purpose == "register":
                code, auth = request(
                    "POST",
                    f"{BASE}/auth/customer/register",
                    body={
                        "phone": test_phone,
                        "otpRequestId": otp_id,
                        "otpCode": otp,
                        "fullName": "Sprint8 Test Customer",
                        "gender": "male",
                        "age": 28,
                        "occupation": "Software Engineer",
                    },
                )
            else:
                code, auth = request(
                    "POST",
                    f"{BASE}/auth/otp/verify",
                    body={"phone": test_phone, "otpRequestId": otp_id, "otpCode": otp},
                )
            customer_token = extract_token(auth) if isinstance(auth, dict) else None
            if code in (200, 201) and customer_token:
                R.ok(f"Customer auth ({purpose})")
                if isinstance(auth, dict):
                    customer_id = (auth.get("data") or {}).get("customer", {}).get("id") or customer_id
            else:
                R.fail("Customer auth", f"HTTP {code} {auth}")

    if customer_token:
        cust_checks = [
            ("GET", "auth/profile"),
            ("GET", "customer-app/services"),
            ("GET", "customer-app/perfumes"),
            ("GET", "customer-app/payment-config"),
            ("GET", "customer-app/promos?page=1&limit=5"),
            ("GET", "customer-app/rewards"),
            ("GET", "customer-app/rewards/history?page=1&limit=5"),
            ("GET", "customer-app/missions"),
            ("GET", "customer-app/dashboard"),
            ("GET", "notifications?page=1&limit=5"),
        ]
        for method, path in cust_checks:
            code, body = request(method, f"{BASE}/{path}", token=customer_token)
            if code in (200, 201):
                R.ok(f"Customer {method} /{path}")
            else:
                R.fail(f"Customer {method} /{path}", f"HTTP {code}")

        # Address
        code, addr = request("GET", f"{BASE}/addresses", token=customer_token)
        if code == 200:
            R.ok("Customer GET /addresses")

        # Create test order
        services_code, services = request("GET", f"{BASE}/customer-app/services", token=customer_token)
        perfumes_code, perfumes = request("GET", f"{BASE}/customer-app/perfumes", token=customer_token)
        service_id = None
        perfume_id = None
        service_items = extract_items(services)
        perfume_items = extract_items(perfumes)
        if service_items:
            service_id = service_items[0].get("id")
        if perfume_items:
            perfume_id = perfume_items[0].get("id")

        order_id = None
        order_number = None
        if service_id:
            order_body: dict[str, Any] = {
                "items": [{"serviceId": service_id, "quantity": 2}],
                "pickupRequired": False,
                "deliveryRequired": False,
                "paymentMethod": "CASH",
            }
            if perfume_id:
                order_body["perfumeId"] = perfume_id
            code, order_resp = request(
                "POST",
                f"{BASE}/customer-app/orders",
                token=customer_token,
                body=order_body,
            )
            if code in (200, 201) and isinstance(order_resp, dict):
                order = order_resp.get("data") or {}
                order_id = order.get("id")
                order_number = order.get("orderNumber")
                R.notes["test_order"] = {
                    "orderId": order_id,
                    "orderNumber": order_number,
                    "customerId": customer_id,
                    "serviceId": service_id,
                    "perfumeId": perfume_id,
                    "subtotal": order.get("subtotal"),
                    "tax": order.get("taxAmount"),
                    "discount": order.get("discountAmount"),
                    "total": order.get("totalAmount"),
                    "paymentStatus": order.get("paymentStatus"),
                    "status": order.get("status"),
                }
                R.ok("Customer create test order")
            else:
                R.fail("Customer create test order", f"HTTP {code} {order_resp}")

        # Cross-platform order verify
        if order_id and owner:
            code, staff_order = request("GET", f"{BASE}/orders/{order_id}", token=owner)
            if code == 200 and isinstance(staff_order, dict):
                so = staff_order.get("data") or {}
                if so.get("id") == order_id:
                    R.ok("Cross-platform order ID match (staff)")
                    staff_service_fee = so.get("serviceFee")
                    if perfume_id and staff_service_fee and float(staff_service_fee) > 0:
                        R.ok("Cross-platform perfume persisted via serviceFee")
                    elif perfume_id:
                        R.fail(
                            "Cross-platform perfume match",
                            f"serviceFee={staff_service_fee}",
                        )
                else:
                    R.fail("Cross-platform order ID match", str(so))
            else:
                R.fail("Staff GET order", f"HTTP {code}")

        # Wallet top-up + confirm (manual flow)
        code, wallet_before = request("GET", f"{BASE}/customer-app/rewards", token=customer_token)
        initial_points = None
        if isinstance(wallet_before, dict):
            initial_points = (wallet_before.get("data") or {}).get("points")

        code, topup = request(
            "POST",
            f"{BASE}/customer-app/wallet/top-up",
            token=customer_token,
            body={"amount": 25000, "paymentMethod": "BANK_TRANSFER"},
        )
        if code in (200, 201) and isinstance(topup, dict):
            req_id = (topup.get("data") or {}).get("id") or (topup.get("data") or {}).get("requestId")
            if req_id and owner:
                code, confirm = request(
                    "POST",
                    f"{BASE}/customer-app/wallet/top-up/{req_id}/confirm",
                    token=customer_token,
                )
                if code in (200, 201):
                    R.ok("Wallet top-up confirm flow")
                else:
                    R.fail("Wallet top-up confirm", f"HTTP {code} {confirm}")
            else:
                R.ok("Wallet top-up initiated")
        else:
            R.fail("Wallet top-up", f"HTTP {code} {topup}")

        # Missions claim (double claim test)
        code, missions = request("GET", f"{BASE}/customer-app/missions", token=customer_token)
        mission_items = extract_items(missions)
        mission_id = None
        for m in mission_items:
            if m.get("status") == "CLAIMABLE" or m.get("canClaim"):
                mission_id = m.get("id")
                break
        if mission_id:
            code, claim1 = request(
                "POST",
                f"{BASE}/customer-app/missions/{mission_id}/claim",
                token=customer_token,
            )
            if code in (200, 201):
                R.ok("Mission claim")
                code2, claim2 = request(
                    "POST",
                    f"{BASE}/customer-app/missions/{mission_id}/claim",
                    token=customer_token,
                )
                if code2 in (400, 409, 422):
                    R.ok("Mission double-claim rejected")
                else:
                    R.fail("Mission double-claim rejected", f"HTTP {code2}")
            else:
                R.fail("Mission claim", f"HTTP {code} {claim1}")
        else:
            R.notes["missions"] = "No claimable mission at test time"

        # Customer service ticket
        code, ticket = request(
            "POST",
            f"{BASE}/customer-app/support/tickets",
            token=customer_token,
            body={
                "category": "PERTANYAAN",
                "subject": "Sprint8 test ticket",
                "message": "Automated E2E test message",
            },
        )
        ticket_id = None
        if code in (200, 201) and isinstance(ticket, dict):
            ticket_id = (ticket.get("data") or {}).get("id")
            R.ok("Customer service ticket create")
            if ticket_id and owner:
                code, reply = request(
                    "POST",
                    f"{BASE}/customer-service/tickets/{ticket_id}/messages",
                    token=owner,
                    body={"message": "Staff reply Sprint8"},
                )
                if code in (200, 201):
                    R.ok("Staff CS reply")
                else:
                    R.fail("Staff CS reply", f"HTTP {code} {reply}")
        else:
            R.fail("Customer service ticket create", f"HTTP {code} {ticket}")

        # Ownership: second customer cannot read first customer's order
        log_pos2 = 0
        other_phone = "081900000802"
        _, reg_send2 = request(
            "POST",
            f"{BASE}/auth/otp/send",
            body={"phone": other_phone, "purpose": "register"},
        )
        time.sleep(0.3)
        otp2 = extract_otp_from_log(other_phone[-4:], log_pos2)
        other_token = None
        if otp2 and isinstance(reg_send2, dict):
            otp_id2 = (reg_send2.get("data") or {}).get("otpRequestId", "")
            code, reg2 = request(
                "POST",
                f"{BASE}/auth/customer/register",
                body={
                    "phone": other_phone,
                    "otpRequestId": otp_id2,
                    "otpCode": otp2,
                    "fullName": "Sprint8 Other Customer",
                    "gender": "female",
                    "age": 30,
                    "occupation": "Tester",
                },
            )
            other_token = extract_token(reg2) if isinstance(reg2, dict) else None
        if order_id and other_token:
            code, forbidden = request(
                "GET",
                f"{BASE}/customer-app/orders/{order_id}",
                token=other_token,
            )
            if code in (403, 404):
                R.ok("Ownership customer B cannot access customer A order")
            else:
                R.fail("Ownership order isolation", f"HTTP {code}")

    # Admin endpoints (owner token)
    if owner:
        for path in ["admin/dashboard", "admin/settings/company", "admin/audit-logs?page=1&limit=5"]:
            code, _ = request("GET", f"{BASE}/{path}", token=owner)
            if code == 200:
                R.ok(f"Admin {path}")
            else:
                R.fail(f"Admin {path}", f"HTTP {code}")

    # Receipt + numbering settings roundtrip
    if owner:
        code, receipt = request("GET", f"{BASE}/settings/receipt", token=owner)
        if code == 200:
            R.ok("Receipt settings GET")
        code, numbering = request("GET", f"{BASE}/settings/numbering", token=owner)
        if code == 200:
            R.ok("Numbering settings GET")

    R.block("Payment gateway webhook", "ENVIRONMENT DEPENDENCY — no production provider credentials")

    print_report()
    return 0 if not R.failed else 1


def print_report() -> None:
    print("\n=== SPRINT 8 LIVE E2E ===")
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
