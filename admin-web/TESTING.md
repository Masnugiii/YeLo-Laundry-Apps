# Sprint 27 — Finance & Revenue Management Testing

## Prerequisites

- Backend running at `http://localhost:3000`
- Admin web running at `http://localhost:3001`
- `NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api/v1`
- Login with finance-enabled account: `081234567890` / `admin123` (OWNER)
- Real payment and expense transactions in database

## Manual Testing

### Finance Dashboard (`/finance/dashboard`)

- [ ] KPI cards: Today's/Weekly/Monthly/Yearly Revenue, Outstanding, Cash Income, Digital Payment, Expenses, Payroll, Net Profit, AOV
- [ ] Owner Summary section shows today and month revenue/expense/profit
- [ ] Payment History summary: Cash, Transfer, QRIS, Wallet, Outstanding, Refund
- [ ] Charts: Revenue Trend, Expense Trend, Net Profit Trend, Payment Method Distribution, Daily Orders
- [ ] Loading skeleton, error state with retry

### Revenue (`/finance/revenue`)

- [ ] Table columns: Invoice, Order Number, Customer, Payment Method, Amount, Paid Date, Cashier, Status
- [ ] Search by invoice, order, customer, phone
- [ ] Filters: payment method, status, employee (cashier), date range
- [ ] Pagination works
- [ ] Export CSV, Excel, Print/PDF
- [ ] Data from `GET /finance/revenue` (real payments)

### Expenses (`/finance/expenses`)

- [ ] Table: Expense Name, Category, Amount, Date, Notes, Status
- [ ] Create expense via form
- [ ] Edit expense
- [ ] Delete expense visible only for OWNER role
- [ ] Delete blocked for non-OWNER (backend enforces)
- [ ] Category filter from `GET /expenses/categories`
- [ ] Search and date filters
- [ ] Export CSV, Excel, Print/PDF

### Profit & Loss (`/finance/profit-loss`)

- [ ] Summary cards: Revenue, Expenses, Payroll, Gross Profit, Operating Profit, Net Profit
- [ ] Period selector: daily, weekly, monthly, yearly
- [ ] Date range filter
- [ ] Period breakdown table
- [ ] Export and print work
- [ ] Data from `GET /finance/profit-loss`

### Cash Flow (`/finance/cash-flow`)

- [ ] Summary: Money In, Money Out, Ending Balance
- [ ] Running balance column in entries table
- [ ] Period and date filters
- [ ] Export and print work
- [ ] Data from `GET /finance/cash-flow`

## Regression Testing

- [ ] Main dashboard (`/`) still loads
- [ ] Orders, customers, employees, production modules unaffected
- [ ] Payroll page (`/finance/payroll`) still accessible
- [ ] Invoices page still accessible
- [ ] No mock/hardcoded financial data in UI

## Acceptance Testing

- [ ] Finance Dashboard works
- [ ] Revenue page works
- [ ] Expense page works (CRUD)
- [ ] Profit & Loss works
- [ ] Cash Flow works
- [ ] Charts work
- [ ] Filters work
- [ ] Export works (CSV, Excel, Print/PDF)
- [ ] Print works for all report pages
- [ ] Backend APIs only — no mock data
- [ ] TypeScript compile success
- [ ] ESLint passes
- [ ] `npm run build` succeeds (backend + admin-web)

## API Endpoints Used

| Feature | Endpoint |
|---------|----------|
| Dashboard KPIs & charts | `GET /finance/dashboard` |
| Revenue list | `GET /finance/revenue` |
| Expense list | `GET /expenses` |
| Expense categories | `GET /expenses/categories` |
| Create expense | `POST /expenses` |
| Update expense | `PATCH /expenses/:id` |
| Delete expense (OWNER) | `DELETE /expenses/:id` |
| Profit & Loss | `GET /finance/profit-loss` |
| Cash Flow | `GET /finance/cash-flow` |
| Payment history summary | `GET /finance/payment-history` |
| Employees filter | `GET /employees` |

---

# Sprint 28 — Payroll Engine Testing

## Prerequisites

- Backend running at `http://localhost:3000`
- Admin web running at `http://localhost:3001`
- `NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api/v1`
- Run migration: `npx prisma migrate deploy` (payroll tables)
- Login as OWNER: `081234567890` / `admin123`
- Real attendance and production data in database

## Manual Testing

### Payroll Dashboard (`/finance/payroll`)

- [ ] KPI cards: Current Period, Employees Waiting, Estimated Payroll, Paid Payroll, Total Bonus, Total Deduction
- [ ] Calculate payroll for current period creates records from real attendance + production
- [ ] Payroll list columns: Payroll Number, Employee, Code, Role, Period, Production Kg/Items, Attendance, Bonus, Deduction, Gross, Net, Status, Action
- [ ] Filters: employee, role, status, period start/end
- [ ] Pagination works
- [ ] Export CSV, Excel, Print/PDF
- [ ] Approve Selected visible only for OWNER
- [ ] Loading skeleton, error state with retry, empty state

### Payroll Detail (`/finance/payroll/[id]`)

- [ ] Employee, position, payroll period shown
- [ ] Attendance: Present, Absent, Late, Leave
- [ ] Production: Laundry Kg/Piece, Ironing Kg/Piece, Orders Finished
- [ ] Bonus and deduction lists
- [ ] Salary detail breakdown
- [ ] Approval history timeline
- [ ] Payment history
- [ ] Approve button (OWNER only, CALCULATED status)
- [ ] Record Payment (APPROVED status) — Cash, Transfer, Wallet
- [ ] Payslip print with signature lines

### Salary Rules (`/finance/payroll/settings`)

- [ ] Laundry Kg/Piece rates, Ironing Kg/Piece rates
- [ ] Attendance bonus per day
- [ ] Manager/Operator weekly salary
- [ ] Payroll schedule days (1, 8, 16, 24)
- [ ] Period type: weekly, biweekly, monthly
- [ ] Save updates `PATCH /payroll/settings` without code changes

## Regression Testing

- [ ] Finance dashboard payroll amount reflects latest calculated total
- [ ] Sprint 27 finance pages still work
- [ ] Production and attendance modules unaffected
- [ ] Non-OWNER cannot approve payroll (backend enforces)

## Acceptance Testing

- [ ] Payroll Dashboard works
- [ ] Payroll Calculation works (real production + attendance)
- [ ] Salary Rule Configuration works
- [ ] Attendance Integration works
- [ ] Production Integration works
- [ ] Payroll Approval workflow: Draft → Calculated → Approved → Paid
- [ ] Payroll Payment works (creates cashflow entry)
- [ ] Payslip works
- [ ] Export works (CSV, Excel, Print/PDF)
- [ ] Backend APIs only — no mock data
- [ ] TypeScript compile success
- [ ] ESLint passes
- [ ] `npm run build` succeeds (backend + admin-web)

## API Endpoints Used

| Feature | Endpoint |
|---------|----------|
| Dashboard KPIs | `GET /payroll/dashboard` |
| Payroll list | `GET /payroll` |
| Payroll detail | `GET /payroll/:id` |
| Salary rules | `GET /payroll/settings` |
| Update rules | `PATCH /payroll/settings` |
| Calculate | `POST /payroll/calculate` |
| Approve (OWNER) | `POST /payroll/approve` |
| Pay | `POST /payroll/pay` |
| Report | `GET /payroll/report` |
| Employees filter | `GET /employees` |

---

# Sprint 29 — Customer Loyalty Platform Testing

## Prerequisites

- Backend running at `http://localhost:3000`
- Admin web at `http://localhost:3001`
- Run migration: `npx prisma migrate deploy`
- Login as OWNER: `081234567890` / `admin123`

## Manual Testing

### Yelo Wallet (`/operations/customers/wallet`)

- [ ] Dashboard KPIs and wallet history with export
- [ ] Top Up with cashflow integration
- [ ] Filter by customer

### Loyalty Settings (`/settings/loyalty`)

- [ ] Point rules, membership tiers, cashback, vouchers
- [ ] Save without code changes

### Customer Detail

- [ ] Loyalty section with wallet, points, membership, vouchers

### Order Integration

- [ ] Complete paid order → points + cashback (if enabled)

## API Endpoints

| Feature | Endpoint |
|---------|----------|
| Wallet | `GET /wallet`, `GET /wallet/history`, `POST /wallet/topup` |
| Reward | `GET /reward`, `GET /reward/history`, `POST /reward/bonus` |
| Membership | `GET /membership` |
| Customer loyalty | `GET /customers/:id/loyalty` |
| Voucher | `GET /voucher`, `POST /voucher` |
| Settings | `GET /loyalty/settings`, `PATCH /loyalty/settings` |
| Reports | `GET /loyalty/report` |

---

# Sprint 30 — Business Intelligence & Reports Testing

## Prerequisites

- Backend running at `http://localhost:3000`
- Admin web running at `http://localhost:3001`
- `NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api/v1`
- Login: `081234567890` / `admin123` (OWNER) or Manager account with `reports` permission
- Real transactional data in database (orders, payments, payroll, wallet, reward points)

## Permissions

- [ ] OWNER and MANAGER can access all BI pages except Forecast and Export Center
- [ ] OWNER only: `/bi/forecast`, `/bi/export`, `GET /reports/forecast`, `GET /reports/scheduler`
- [ ] Non-owner redirected from Forecast and Export Center to Executive Dashboard
- [ ] API returns 403 for non-owner on forecast/scheduler endpoints

## Filters (all BI pages)

- [ ] Today, Yesterday, Last 7 Days, Last 30 Days, This Month, Last Month presets
- [ ] Custom date range (dateFrom + dateTo)
- [ ] Apply button refreshes data
- [ ] No mock/hardcoded numbers — values change with database data

## Executive Dashboard (`/bi/executive`)

- [ ] KPIs: revenue today/week/month, net profit, orders, AOV, laundry kg, pickup/delivery, attendance, payroll, wallet, reward points, customers
- [ ] Charts: order status bar chart, revenue snapshot line chart
- [ ] Export CSV, Excel, PDF/Print

## Sales Report (`/bi/sales`)

- [ ] Summary: total revenue, average/largest transaction, count
- [ ] Charts: revenue per day/week, service pie, top employees bar
- [ ] Export works

## Customer Analytics (`/bi/customers`)

- [ ] New, returning, inactive, active customers
- [ ] Top customers table with CLV
- [ ] Membership distribution pie chart
- [ ] Customer trend line chart

## Production Analytics (`/bi/production`)

- [ ] Kg processed, pieces, avg completion time, delayed orders
- [ ] Production trend and per-employee bar chart

## Employee Performance (`/bi/employees`)

- [ ] Table: attendance, orders, kg, bonus, payroll, revenue
- [ ] Revenue handled bar chart

## Finance Analytics (`/bi/finance`)

- [ ] Revenue, expense, payroll, gross/net profit, cash flow, operating margin
- [ ] Area chart (revenue vs expenses) and cash flow line chart

## Payroll Analytics (`/bi/payroll`)

- [ ] Summary totals and history table
- [ ] By employee bar chart, by role pie chart

## Wallet Analytics (`/bi/wallet`)

- [ ] Top up, payment, refund, adjustment, balance
- [ ] Breakdown pie and activity trend

## Membership Analytics (`/bi/membership`)

- [ ] Tier distribution (Regular, Silver, Gold, Platinum)
- [ ] Points growth chart and upgrade history table

## Forecast (`/bi/forecast`) — Owner only

- [ ] Next 7/30 day revenue and orders estimates
- [ ] Payroll and production forecasts
- [ ] Disclaimer shown

## Export Center (`/bi/export`) — Owner only

- [ ] Combined export CSV/Excel/PDF
- [ ] Links to all report pages
- [ ] Scheduler architecture preview (jobs listed, not executed)

## API Endpoints

| Report | Endpoint |
|--------|----------|
| Executive Dashboard | `GET /reports/dashboard` |
| Sales | `GET /reports/sales` |
| Customers | `GET /reports/customers` |
| Production | `GET /reports/production` |
| Employees | `GET /reports/employees` |
| Finance | `GET /reports/finance` |
| Payroll | `GET /reports/payroll` |
| Wallet | `GET /reports/wallet` |
| Membership | `GET /reports/membership` |
| Forecast | `GET /reports/forecast` |
| Scheduler | `GET /reports/scheduler` |

Query params: `period`, `dateFrom`, `dateTo`, `employeeId`, `customerId`

