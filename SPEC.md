# Build a Production-Ready Daftra Financial Intelligence Dashboard

أريد بناء Web Application احترافي كامل عبارة عن **Financial, Sales, Collections & Management Dashboard** متصل مباشرة ببرنامج **Daftra / دفترة** من خلال الـAPI.

المشروع ليس مجرد Dashboard للمبيعات، بل **Management Financial Intelligence System** للإدارة العليا والمحاسبة، ويجب أن يعتمد أساسًا على **قيود اليومية General Ledger / Journal Entries** كمصدر الحقيقة المحاسبي الرئيسي.

---

# 1. المبدأ المحاسبي الأساسي — مهم جدًا

يجب تطبيق Architecture باسم:

**Ledger-First / Journal-Driven Accounting Dashboard**

بمعنى:

كل رقم مالي رسمي يظهر في الـDashboard يجب حسابه أساسًا من:

- Journal Entries
- Journal Transactions
- Chart of Accounts
- Journal Account Categories
- Debit / Credit movements

ولا يتم اعتبار إجماليات الفواتير أو المصروفات أو المدفوعات هي المصدر المحاسبي النهائي.

استخدم بقية Daftra APIs مثل:

- Invoices
- Invoice Payments
- Client Payments
- Expenses
- Clients
- Suppliers
- Products
- Treasuries
- Branches
- Staff
- Cost Centers

لأغراض:

1. Enrichment.
2. Drill-down.
3. Document details.
4. Operational analysis.
5. Reconciliation.
6. كشف الاختلافات بين المستند والقيد.

القاعدة:

**Journal Entries = Accounting Source of Truth**

**Invoices / Payments / Expenses = Operational Source + Reconciliation Layer**

---

# 2. Daftra API Integration

اعمل Integration Layer مستقلة باسم:

`Daftra Integration Service`

ويتم وضع بيانات الاتصال في Environment Variables فقط:

```
DAFTRA_SUBDOMAIN=
DAFTRA_API_KEY=
DAFTRA_ACCESS_TOKEN=
DAFTRA_BASE_CURRENCY=

```

لا تضع API Key أو Access Token نهائيًا داخل Frontend JavaScript.

استخدم Server-side requests فقط.

دعم:

- API Key Authentication.
- Bearer Token / OAuth2 عندما يكون مستخدمًا.
- Pagination.
- Retry logic.
- Rate-limit handling.
- Request timeout.
- Error logging.
- Incremental synchronization.
- Full synchronization.
- Manual Refresh.

اعرض دائمًا:

**Last Successful Sync**
**Sync Status**
**API Health**

---

# 3. Daftra Data Sources

ابنِ Data Connectors للمصادر التالية حسب أحدث Daftra API documentation.

## Accounting

استخدم:

```
/journals

```

لاستيراد:

- Journal ID
- Journal Number
- Date
- Description
- Entity Type
- Entity ID
- Draft Status
- Automatic / Manual
- Staff
- Currency
- Currency Rate
- Total Debit
- Total Credit

والأهم:

`JournalTransaction[]`

واستخرج لكل Journal Line:

- journal\_account\_id
- debit
- credit
- currency\_debit
- currency\_credit
- description

---

استخدم:

```
/journal_accounts

```

لبناء Chart of Accounts.

احفظ:

- Account ID
- Account Code
- Account Name
- Account Category
- Parent Categories
- Account Type
- Total Debit
- Total Credit
- Entity Type
- Entity ID

---

استخدم:

```
/journal_cats

```

لبناء Account Hierarchy.

أنشئ شجرة حسابات Hierarchical Tree تسمح بمعرفة:

- Assets
- Current Assets
- Cash
- Banks
- Accounts Receivable
- Inventory
- Fixed Assets
- Liabilities
- Accounts Payable
- Equity
- Revenue
- Sales
- Cost of Goods Sold
- Operating Expenses
- Other Income
- Other Expenses
- Taxes

لا تعتمد على أسماء الحسابات hard-coded فقط.

ابنِ Account Mapping Engine يعتمد على:

1. Account ID.
2. Account Code.
3. Parent Category.
4. Journal Category.
5. Account hierarchy.

وأضف صفحة Settings تسمح للمحاسب بتعديل Classification بدون تغيير الكود.

---

# 4. Sales & Invoice Data

استخدم:

```
/invoices

```

ويفضل تحميل التفاصيل اللازمة للمستندات والعميل والعناصر والمدفوعات عند الحاجة.

استورد على الأقل:

- Invoice ID
- Number
- Date
- Due Date
- Client
- Branch
- Staff / Salesperson
- Currency
- Subtotal
- Discount
- Total
- Paid
- Unpaid
- Refund
- Payment Status
- Draft Status
- Items
- Taxes
- PDF / document link if available.

لكن:

**لا تستخدم Invoice Total مباشرة كإيراد محاسبي نهائي.**

يجب مقارنة قيمة Sales Revenue الناتجة من القيود مع قيمة الفواتير.

---

# 5. Collections

استخدم:

```
/invoice_payments

```

وكذلك عند الحاجة:

```
/client_payments

```

لاستيراد:

- Payment ID
- Invoice ID
- Client ID
- Payment Date
- Payment Method
- Amount
- Transaction ID
- Staff
- Status

ادعم Opening Balances بشكل منفصل ولا تخلطها تلقائيًا مع تحصيلات الفترة التشغيلية.

---

# 6. Expenses

استخدم:

```
/expenses

```

لإضافة Operational Detail للمصروفات.

استورد:

- Expense ID
- Date
- Amount
- Currency
- Vendor
- Category
- Note
- Client
- Journal Account
- Staff

لكن مصروفات الـP&L النهائية يجب أن تأتي من Debit movements الخاصة بحسابات المصروفات في الـGeneral Ledger.

---

# 7. Cash & Banks

استخدم:

```
/treasuries

```

لاستيراد:

- Treasury ID
- Name
- Type
- Currency
- Current Balance
- Active Status

ويجب مقارنة Treasury API Balance مع الرصيد المحسوب من القيود.

اعمل Reconciliation Indicator:

```
API Treasury Balance
vs
Ledger Calculated Balance
=
Difference

```

لو الفرق ليس صفرًا أو تعدى tolerance محدد، اظهر Warning.

---

# 8. Branches / Cost Centers

ادعم:

- Branches
- Cost Centers
- Staff
- Salesperson

واجعل كل Dashboard قابل للفلترة حسب:

- All Company
- Branch
- Cost Center
- Salesperson
- Client
- Supplier
- Account
- Product
- Product Category
- Payment Method
- Currency

---

# 9. Executive Dashboard

الصفحة الرئيسية يجب أن تكون Executive Dashboard بسيطة وقوية.

## KPI Row 1

اعرض:

### Net Sales

صافي المبيعات للفترة.

### Cash Collections

إجمالي التحصيلات النقدية والبنكية.

### Total Expenses

إجمالي المصروفات.

### Gross Profit

مجمل الربح.

### Gross Profit Margin %

### Net Profit

### Net Profit Margin %

### Total Cash & Bank Balance

---

## KPI Row 2

اعرض:

### Accounts Receivable

إجمالي أرصدة العملاء المدينة.

### Overdue Receivables

### Collection Rate %

```
Collections / Collectible Sales

```

### DSO — Days Sales Outstanding

### Accounts Payable

### Current Month Sales Growth %

### YoY Sales Growth %

### Expense Growth %

---

# 10. KPI Comparison

كل KPI Card يجب أن يعرض:

- Current Period.
- Previous Period.
- Change Amount.
- Change %.
- Up / Down Indicator.
- Target إن وجد.
- Variance vs Target.

مثال:

```
Net Sales
3,420,000 EGP

▲ 12.4%
vs previous month

```

النقر على أي KPI يفتح Drill-down.

---

# 11. Sales Dashboard

أنشئ صفحة مستقلة باسم:

**المبيعات**

تحتوي على:

- Gross Sales.
- Sales Returns.
- Net Sales.
- Discounts.
- Taxes.
- Number of Invoices.
- Average Invoice Value.
- Paid Sales.
- Credit Sales.
- Outstanding Sales.
- Sales Growth.

Charts:

### Net Sales Trend

Daily / Weekly / Monthly.

### Sales by Branch

### Sales by Salesperson

### Sales by Client

### Sales by Product

### Sales by Category

### Sales by Invoice Status

### Sales vs Previous Period

### Sales YoY

أضف:

**Top 10 Customers**

**Top 10 Products**

**Top 10 Salespeople**

---

# 12. Collections Dashboard

أنشئ صفحة:

**التحصيلات**

اعرض:

- Total Collections.
- Cash Collections.
- Bank Collections.
- Card / Electronic Collections.
- Number of Payments.
- Average Payment.
- Collection Rate.
- Outstanding Receivables.
- Overdue Receivables.

Charts:

- Collections Trend.
- Collections by Payment Method.
- Collections by Branch.
- Collections by Salesperson.
- Collections by Client.
- Sales vs Collections.

اعمل Chart مهم جدًا:

## Sales vs Collections

اعرض خطين:

```
Net Sales
Cash Collections

```

على نفس Timeline.

الهدف هو اكتشاف:

**هل المبيعات تنمو أسرع من التحصيلات؟**

---

# 13. Accounts Receivable Aging

أنشئ Aging Dashboard:

```
Current
1–30 Days
31–60 Days
61–90 Days
91–120 Days
120+ Days

```

اعرض:

- Amount.
- % of Total AR.
- Number of Clients.
- Number of Invoices.

اعمل:

**Top Overdue Customers**

ويظهر لكل عميل:

- Total Sales.
- Total Paid.
- Outstanding.
- Overdue.
- Oldest Unpaid Invoice.
- Average Days to Pay.
- Credit Limit if available.

---

# 14. Cash Dashboard

أنشئ صفحة:

**الخزائن والسيولة**

اعرض:

### Total Liquidity

إجمالي أرصدة:

- Cash.
- Banks.
- Treasuries.

ثم:

- Opening Cash.
- Cash Inflows.
- Cash Outflows.
- Closing Cash.

Charts:

### Cash Balance Trend

### Cash In vs Cash Out

### Balance by Treasury / Bank

### Collections by Treasury

### Expenses by Treasury

اعمل Cash Movement Waterfall:

```
Opening Cash
+ Customer Collections
+ Other Income
- Supplier Payments
- Operating Expenses
- Payroll
- Taxes
- Other Outflows
= Closing Cash

```

حسب البيانات المتاحة في القيود.

---

# 15. Expense Dashboard

أنشئ صفحة:

**المصروفات**

KPIs:

- Total Expenses.
- Operating Expenses.
- Expense Growth.
- Expense / Revenue %.
- Average Daily Expense.
- Largest Expense Category.

Charts:

### Expenses Trend

### Expenses by Account

### Expenses by Category

### Expenses by Vendor

### Expenses by Branch

### Expenses by Cost Center

### Expenses Month over Month

أضف:

**Top 10 Expense Categories**

و:

**Top 20 Largest Expense Transactions**

---

# 16. Profitability Dashboard

أنشئ صفحة:

**الربحية**

P&L structure:

```
Net Revenue

- Cost of Goods Sold

= Gross Profit

- Operating Expenses

= Operating Profit

+ Other Income

- Other Expenses

= Net Profit

```

اعرض:

- Gross Margin %.
- Operating Margin %.
- Net Margin %.

Charts:

- Revenue vs Expenses.
- Gross Profit Trend.
- Net Profit Trend.
- Margin Trend.
- Profit by Branch.
- Profit by Cost Center.

---

# 17. Financial Position

اعمل قسم ملخص:

- Cash & Banks.
- Accounts Receivable.
- Inventory.
- Current Assets.
- Fixed Assets.
- Total Assets.
- Accounts Payable.
- Current Liabilities.
- Total Liabilities.
- Equity.

اعرض:

### Current Ratio

### Quick Ratio

إذا كان تصنيف الحسابات يسمح بالحساب الصحيح.

---

# 18. Working Capital KPIs

عند توفر البيانات الكافية احسب:

### DSO

Days Sales Outstanding.

### DPO

Days Payable Outstanding.

### DIO

Days Inventory Outstanding.

### Cash Conversion Cycle

```
CCC = DIO + DSO - DPO

```

ولا تعرض أي KPI إذا البيانات اللازمة غير متوفرة أو التصنيف المحاسبي غير موثوق.

بدل الرقم الوهمي اعرض:

`Insufficient Data`

---

# 19. Journal Audit Dashboard

هذه صفحة أساسية جدًا.

اسمها:

**مراجعة القيود**

اعرض:

- Total Journals.
- Automatic Journals.
- Manual Journals.
- Draft Journals.
- Reversed Journals.
- Debit Total.
- Credit Total.

اعمل Validation:

```
Total Debit = Total Credit

```

لكل قيد.

لو:

```
Debit ≠ Credit

```

اظهر القيد في:

**Accounting Exceptions**

---

# 20. Reconciliation Center

أنشئ صفحة اسمها:

**مركز المطابقة**

تحتوي على Checks مثل:

### Sales

```
Invoice Net Sales
vs
Ledger Sales Revenue

```

### Collections

```
Invoice / Client Payments
vs
Cash & Bank Debit Movements

```

### Expenses

```
Expense Documents
vs
Expense Account Debit Movements

```

### Treasury

```
Daftra Treasury Balance
vs
Ledger Balance

```

### Receivables

```
Invoice Outstanding
vs
Accounts Receivable Ledger

```

اعرض:

```
Source A
Source B
Difference
Status

```

Status:

- Matched.
- Warning.
- Mismatch.
- Missing Data.

---

# 21. Accounting Drill-Down

أي رقم في أي Chart أو KPI يجب أن يكون Clickable.

مثال:

اضغط على:

`Total Expenses`

يفتح:

```
Expense Accounts
↓
Account
↓
Journal Entries
↓
Journal Lines
↓
Source Transaction

```

ويظهر:

- Journal Number.
- Date.
- Account.
- Debit.
- Credit.
- Description.
- Source Type.
- Entity ID.
- Staff.
- Branch.
- Related Document.

إذا Daftra يوفر رابط المستند أو PDF اعرض:

**Open in Daftra**

أو:

**View Document**

---

# 22. Advanced Alerts

أنشئ Smart Alerts Engine.

أمثلة:

### Sales Alert

المبيعات منخفضة أكثر من 20% مقارنة بالفترة السابقة.

### Collection Alert

التحصيل أقل من 70% من المبيعات.

### Expense Alert

المصروفات ارتفعت أكثر من 20%.

### Cash Alert

رصيد السيولة أقل من الحد المحدد.

### Customer Alert

عميل تجاوز Credit Limit.

### Overdue Alert

فاتورة تأخرت أكثر من X يوم.

### Reconciliation Alert

وجود فرق بين الـLedger والمستندات.

### Accounting Alert

وجود قيد Debit لا يساوي Credit.

---

# 23. Management Insights

أنشئ قسم:

**Insights**

يعطي جمل قصيرة مبنية فقط على الأرقام الفعلية.

مثال:

```
المبيعات ارتفعت 12.6% عن الشهر السابق.

```

```
التحصيلات نمت 4.2% فقط، وهي أبطأ من نمو المبيعات.

```

```
34% من أرصدة العملاء تجاوزت 60 يومًا.

```

```
مصروفات النقل ارتفعت 27% خلال الشهر الحالي.

```

ممنوع توليد Insight بدون بيانات تدعمه.

---

# 24. Filters

ضع Global Filter Bar ثابت أعلى جميع الصفحات.

يشمل:

### Date

Quick options:

- Today
- Yesterday
- This Week
- This Month
- Last Month
- This Quarter
- Last Quarter
- This Year
- Last Year
- Custom Range

ثم:

- Branch.
- Cost Center.
- Salesperson.
- Client.
- Supplier.
- Product.
- Product Category.
- Payment Method.
- Currency.

أي Filter يتم اختياره يجب أن يؤثر على كل KPIs وCharts في الصفحة.

---

# 25. Multi-Currency

لا تفترض أن كل المعاملات EGP.

استخدم:

- transaction currency.
- currency rate.
- company base currency.

كل Dashboard يجب أن يسمح بعرض:

```
Original Currency
Company Base Currency

```

واجعل المقارنات المالية الرئيسية Base Currency.

---

# 26. Returns / Credit Notes / Reversals

يجب التعامل محاسبيًا بطريقة صحيحة مع:

- Sales Returns.
- Credit Notes.
- Refunds.
- Reversed Journal Entries.
- Cancelled Transactions.

لا يتم إضافة المرتجعات كمبيعات موجبة.

اعرض:

```
Gross Sales
- Sales Returns
= Net Sales

```

---

# 27. Draft Data

بشكل افتراضي:

**لا تدخل Draft Journals في الأرقام الرسمية.**

وفر Toggle:

`Include Draft Entries`

ويكون OFF افتراضيًا.

---

# 28. Sync Architecture

لا تجعل المتصفح يسحب آلاف السجلات من Daftra مباشرة.

استخدم Architecture:

```
Daftra API
      ↓
Backend Integration Service
      ↓
Normalization Layer
      ↓
Local Database / Cache
      ↓
Accounting Calculation Engine
      ↓
Dashboard API
      ↓
Frontend

```

يفضل استخدام PostgreSQL.

اعمل جداول منظمة مثل:

```
daftra_journals
daftra_journal_lines
daftra_accounts
daftra_account_categories
daftra_invoices
daftra_invoice_items
daftra_payments
daftra_clients
daftra_expenses
daftra_treasuries
daftra_branches
daftra_cost_centers
sync_logs

```

---

# 29. Incremental Sync

بعد أول Full Sync لا تسحب كل التاريخ كل مرة.

استخدم:

- created date.
- modified date.
- transaction date.
- IDs.

لعمل incremental update عندما يسمح الـendpoint بذلك.

ومع ذلك نفذ periodic reconciliation للتأكد من أن السجلات القديمة المعدلة لم تُفقد.

---

# 30. Pagination — Mandatory

ممنوع افتراض أن أول API Response يحتوي كل البيانات.

اعمل Generic Pagination Handler يقوم بجلب:

```
Page 1
Page 2
Page 3
...
Until Last Page

```

واستخدم pagination metadata من Daftra.

---

# 31. Data Quality

أنشئ:

**Data Quality Panel**

اعرض:

- Missing Accounts.
- Unknown Account Classification.
- Missing Client Links.
- Missing Invoice Links.
- Missing Branch.
- Missing Currency Rate.
- Unbalanced Journals.
- Duplicate Transactions.
- Failed API Requests.
- Reconciliation Differences.

اعرض Data Quality Score من 0 إلى 100.

---

# 32. Account Mapping Settings

أنشئ Settings Page تسمح للمحاسب بتحديد الحسابات المستخدمة في:

- Sales Revenue.
- Sales Returns.
- COGS.
- Operating Expenses.
- Cash.
- Banks.
- AR.
- AP.
- Inventory.
- VAT Input.
- VAT Output.
- Other Income.
- Other Expense.

حاول اكتشافها تلقائيًا من Chart of Accounts hierarchy أولًا.

ثم يسمح للمستخدم بتعديل الـMapping.

---

# 33. Comparison Engine

كل Dashboard يدعم:

- Previous Period.
- Previous Month.
- Previous Quarter.
- Previous Year.
- Year over Year.
- Month over Month.
- YTD.
- Prior Year YTD.

مثال:

```
2026 YTD
vs
2025 YTD

```

---

# 34. Goals & Targets

لو Daftra لا يوفر Target محدد، اسمح بإضافة Management Targets داخليًا داخل الـDashboard.

لكن وضّح بصريًا الفرق:

```
Actual = Daftra Data
Target = Dashboard Planning Data

```

لا تخلط الاثنين.

---

# 35. UI / UX

الواجهة الأساسية:

**Arabic RTL**

مع إمكانية:

**Arabic / English**

استخدم تصميم:

- Modern.
- Premium.
- Executive.
- Clean.
- Minimal.
- Professional accounting style.

تجنب كثرة الألوان.

استخدم:

- Green = positive / healthy.
- Red = negative / alert.
- Amber = warning.
- Neutral colors = normal financial information.

لكن لا تستخدم الأخضر تلقائيًا لكل زيادة؛ فزيادة المصروف مثلًا تعتبر سلبية.

---

# 36. Main Navigation

Sidebar:

```
نظرة عامة
المبيعات
التحصيلات
العملاء والمديونيات
الخزائن والسيولة
المصروفات
الربحية
المشتريات والموردون
المركز المالي
مراجعة القيود
مركز المطابقة
التقارير
الإعدادات
حالة المزامنة

```

---

# 37. Export

وفر:

- Export Excel.
- CSV.
- PDF.
- Print.

وأي Table يمكن تصدير بياناتها بعد تطبيق Filters الحالية.

---

# 38. Tables

كل Detail Table يدعم:

- Search.
- Sort.
- Pagination.
- Column Filters.
- Show / Hide Columns.
- Export.
- Sticky Header.
- Total Row.

---

# 39. Suggested Technology

استخدم Stack حديث ومستقر مثل:

### Frontend

- Next.js
- React
- TypeScript
- Tailwind CSS
- shadcn/ui

### Charts

- Recharts أو Apache ECharts.

### Backend

- Next.js Server API / Node.js.

### Database

- PostgreSQL.

### ORM

- Prisma.

### Authentication

- Secure role-based authentication.

---

# 40. Security

ممنوع:

- Exposing Daftra API Key.
- Storing secrets in frontend.
- Logging API credentials.
- Returning secrets through API responses.

استخدم:

```
.env
Server Side API Calls
Secure Secrets

```

---

# 41. Read-Only Daftra Mode

في النسخة الأولى اجعل التكامل:

**READ ONLY**

ممنوع إنشاء أو تعديل أو حذف أي:

- Invoice.
- Payment.
- Expense.
- Journal.
- Client.

من خلال Daftra.

الـDashboard للتحليل فقط.

---

# 42. User Roles

أنشئ Roles:

### Admin

كل شيء.

### Owner / CEO

كل الـDashboards بدون إعدادات تقنية حساسة.

### CFO / Accountant

كل الأرقام المحاسبية وReconciliation وJournal Drill-down.

### Sales Manager

Sales + Collections + Customers.

### Branch Manager

بيانات فرعه فقط.

---

# 43. Performance

الهدف:

Dashboard Overview تفتح بسرعة حتى لو Daftra يحتوي آلاف أو مئات آلاف الحركات.

لا تعمل hundreds of API calls في كل فتح صفحة.

استخدم:

- Local caching.
- Aggregations.
- Indexed database tables.
- Server-side calculations.

---

# 44. Loading State

لا تعرض بيانات وهمية على أنها حقيقية.

عند عدم وجود اتصال:

اعرض:

```
Waiting for Daftra connection

```

أو:

```
No synchronized data yet

```

وليس أرقامًا Demo غير موضحة.

---

# 45. Connection Setup Screen

أنشئ صفحة:

**ربط دفترة**

تحتوي على:

- Daftra Subdomain.
- Authentication Method.
- API Key.
- Access Token إذا لزم.
- Test Connection Button.

بعد الضغط:

`Test Connection`

اعرض:

```
Connection Successful

```

أو Error واضح.

ثم:

`Start Initial Sync`

---

# 46. Initial Sync Screen

أثناء أول Sync اعرض Progress:

```
Accounts          ✓
Account Categories ✓
Journals          12,430 records
Invoices           4,820 records
Payments           6,150 records
Expenses           1,290 records
Clients              870 records
Treasuries             8 records

```

ثم:

```
Building Financial Model...

```

ثم:

```
Reconciling Accounts...

```

---

# 47. Dashboard Header

اعرض دائمًا:

```
Financial Intelligence Dashboard

Data Source: Daftra
Last Sync: [time]
Status: Live / Synced

```

مع زر:

**تحديث البيانات**

---

# 48. Critical Accounting Requirement

لا تكتب المعادلات اعتمادًا على أسماء حسابات ثابتة مثل:

```
if account_name == "Sales"

```

لأن أسماء الحسابات قد تكون عربية أو إنجليزية أو مخصصة.

اعتمد على:

```
Account ID
Account Code
Chart of Accounts Hierarchy
Account Category
Configurable Account Mapping

```

---

# 49. Traceability

أي رقم مالي في النظام يجب أن يكون Traceable.

يجب أن يستطيع المستخدم الانتقال من:

```
Dashboard KPI
↓
Calculation
↓
Account
↓
Journal
↓
Journal Line
↓
Original Daftra Entity / Document

```

هذه نقطة أساسية جدًا في المشروع.

---

# 50. Final Acceptance Requirements

لا تعتبر المشروع مكتملًا إلا إذا:

1. تم الاتصال الحقيقي بـDaftra.
2. تم جلب جميع صفحات Pagination.
3. تم بناء Chart of Accounts.
4. تم تحميل Journal Entries.
5. تم تحميل Journal Lines.
6. Debit = Credit يتم مراجعته.
7. المبيعات يتم حسابها من Ledger.
8. المصروفات يتم حسابها من Ledger.
9. الربح يتم حسابه من Ledger.
10. Cash Balance يتم حسابه من Ledger.
11. AR وAP يتم حسابهما من Ledger.
12. يتم استخدام Invoices/Payments/Expenses للمطابقة والتفاصيل.
13. Filters تعمل على كل الأرقام.
14. Drill-down يصل إلى القيد.
15. لا توجد Demo Data مخفية.
16. لا يوجد API Secret داخل Frontend.
17. يوجد Reconciliation Center.
18. يوجد Data Quality Center.
19. يوجد Sync Status.
20. كل الأرقام قابلة للتتبع والمراجعة.

---

# Final Product Goal

أريد Dashboard عندما يفتحه صاحب الشركة يستطيع خلال أقل من دقيقة معرفة:

- بعت بكام؟
- حصلت كام؟
- باقي لي عند العملاء كام؟
- المتأخر كام؟
- صرفت كام؟
- المصروف راح فين؟
- معايا سيولة كام؟
- ربحت كام؟
- هامش الربح كام؟
- أي فرع أفضل؟
- أي مندوب أفضل؟
- أكبر العملاء مديونية مين؟
- هل التحصيل مواكب للمبيعات؟
- هل المصروفات تزيد بشكل خطر؟
- هل فيه اختلاف بين المستندات وقيود اليومية؟
- هل الأرقام المحاسبية متزنة؟

وفي نفس الوقت يستطيع المحاسب الضغط على أي رقم والوصول إلى القيود التي كوّنت هذا الرقم.

**Accuracy, reconciliation, traceability and accounting correctness are more important than visual decoration.**