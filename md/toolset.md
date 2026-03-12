# Molly Digital Toolset Design

12 tools, 63 actions. Each action = a real business operation performed by a specific role.

**Role Legend**: Employee, Supervisor (department manager), HR/HRBP, Finance, Ops (operations/warehouse), CS (customer service), Customer, Candidate, System (automated)

## 1. employee (6 actions)

| Action | Actor | Description |
|---|---|---|
| `search_employees` | Employee | Search employees by name, department, title, or status |
| `get_employee` | Employee | Get employee details (supervisor, salary, permissions, leave balance) |
| `onboard_employee` | HR | Onboard a new hire: create record, assign department, supervisor, salary |
| `update_employee` | HR | Update employee info (title, contact, department transfer, salary adjustment) |
| `search_departments` | Employee | Search departments with manager and HRBP info |
| `update_department` | HR | Change department manager or HRBP |

## 2. recruitment (11 actions)

| Action | Actor | Description |
|---|---|---|
| `search_jds` | Employee | Search job descriptions by department, status, or keyword |
| `post_jd` | Supervisor | Publish a JD when headcount is available (salary range = monthly x 16, HRBP as contact) |
| `update_jd` | Supervisor | Update JD content or close the position |
| `search_candidates` | HR | Search candidates by name, email, or status |
| `register_candidate` | HR | Register a new candidate with resume |
| `search_applications` | HR | Search job applications by status, JD, or candidate |
| `apply_job` | Candidate | Apply to a JD (one application binds to exactly one JD) |
| `screen_resume` | Supervisor | Review resume and decide: proceed to interview or reject |
| `arrange_interview` | HR | Schedule interview round |
| `submit_interview_feedback` | Supervisor/HR | Interviewer submits score (3.0/3.25/3.5/3.75/4.0) and feedback within 2 business days |
| `make_offer` | HR | Negotiate salary (max 120% of JD upper limit); candidate accepts or rejects |

## 3. schedule (3 actions)

| Action | Actor | Description |
|---|---|---|
| `search_events` | Employee | Search events by employee, time range, or status |
| `create_event` | Employee | Create a schedule event |
| `update_event` | Employee | Reschedule or cancel an event |

## 4. okr (4 actions)

| Action | Actor | Description |
|---|---|---|
| `get_okr` | Employee | View OKR by employee, year, quarter, or status |
| `set_okr_goal` | Employee | Set quarterly objectives in consultation with supervisor |
| `submit_okr_review` | Employee | Submit end-of-quarter review summary |
| `rate_okr` | Supervisor | Rate employee performance: S (2.0) / A (1.6) / B (1.0) / C (0.8); supervisor's own OKR rated by their superior |

## 5. salary (3 actions)

| Action | Actor | Description |
|---|---|---|
| `get_salary` | Employee | View salary records by employee, year/month, or payout status |
| `generate_payroll` | Finance | Generate monthly salary slip: base + overtime (3x daily) - unpaid leave deductions + year-end bonus (Jan only) |
| `process_payout` | Finance | Mark salary as paid (on the 15th of the following month) |

## 6. approval (6 actions)

| Action | Actor | Description |
|---|---|---|
| `search_requests` | Employee | Search approval requests (resource + leave, filterable by type and status) |
| `request_resource` | Employee | Request resource (Laptop/Monitor/Mobile/Token) -> auto-generates approval chain: supervisor -> finance |
| `request_leave` | Employee | Request leave or overtime; personal leave draws annual leave first, sick leave draws paid sick leave first |
| `approve_request` | Supervisor/Finance | Approve a pending request (supervisor for leave; supervisor then finance for resource) |
| `reject_request` | Supervisor/Finance | Reject a pending request with reason |
| `get_leave_balance` | Employee | Check remaining leave days (statutory annual / tenure annual / paid sick) |

## 7. product (5 actions)

| Action | Actor | Description |
|---|---|---|
| `search_products` | Customer/Employee | Search products by brand, type, price range, stock, or keyword |
| `get_product` | Customer/Employee | Get product details with full SKU specs (camera: sensor/ISO/mount; lens: focal/aperture/mount) |
| `update_product` | Ops | Update price, stock quantity, special-offer flag, or returnable flag |
| `search_manufacturers` | CS | Search manufacturer contact info (for warranty referral to customers) |

## 8. customer (4 actions)

| Action | Actor | Description |
|---|---|---|
| `search_customers` | CS | Search customers by name, email, phone, or membership tier |
| `get_customer` | CS | Get customer profile (addresses, membership tier, recent spending) |
| `register_customer` | Customer | Register a new account |
| `update_customer` | System/CS | Update info or refresh membership tier (past 6-month completed-order spend: >$1k Platinum 10% off, >$6k Black Gold 20% off + free shipping) |

## 9. order (11 actions)

| Action | Actor | Description |
|---|---|---|
| `search_orders` | Customer/CS | Search orders by customer, status, or time range |
| `get_order` | Customer/CS | Get full order details (items, payment, shipping, refund records) |
| `place_order` | Customer | Place order: snapshot prices, apply membership discount (full-price items only), calculate shipping + handling fee |
| `cancel_order` | Customer/System | Cancel unpaid order (customer voluntary; system auto-cancels: online 1 day, bank transfer 3 days) |
| `pay_order` | Customer | Pay via Online (instant) or Bank_Transfer (sends account details email, 3-day deadline) |
| `confirm_bank_transfer` | Finance | Confirm incoming bank transfers and batch-update order statuses (daily at 11:00) |
| `ship_order` | Ops | Pack and ship: generate tracking number, FedEx_Standard ($10, 3-5 days) or FedEx_Next_Day ($40) |
| `deliver_order` | System/Ops | Mark as delivered based on logistics tracking; starts 7-day auto-confirmation countdown |
| `confirm_receipt` | Customer/System | Customer confirms receipt, or auto-confirms 7 days after delivery; spend counted toward membership tier |
| `request_refund` | Customer | Request return: 7-day no-reason (unopened/original condition) or 14-day quality issue (from delivery date) |
| `handle_refund` | Ops | Warehouse inspects return -> pass/fail; if passed, refund to original payment method within 3 days |

## 10. ticket (3 actions)

| Action | Actor | Description |
|---|---|---|
| `search_tickets` | CS | Search tickets by customer, order, type, status, or priority |
| `open_ticket` | Customer | Open a ticket (Product_Inquiry / Order / Technical_Support / Complaint) |
| `handle_ticket` | CS | Assign handler, reply to customer, resolve or close ticket |

## 11. email (3 actions)

| Action | Actor | Description |
|---|---|---|
| `search_emails` | Employee | Search emails by sender, receiver, subject, or time |
| `send_email` | Employee | Send email with optional CC |
| `revoke_email` | Employee | Revoke a sent email |

## 12. document (4 actions)

| Action | Actor | Description |
|---|---|---|
| `search_documents` | Employee/Customer | Search documents by title, tags, type (Internal/External), or status |
| `get_document` | Employee/Customer | Read document content |
| `publish_document` | Employee | Write and publish a document (Internal for staff, External for customers) |
| `update_document` | Employee | Edit content, update tags, or archive |
