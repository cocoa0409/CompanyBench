# Molly Digital Toolset Design

13 tools, 59 actions.

## 1. employee (5 actions)

| Action | Description |
|---|---|
| `search_employees` | Query employees |
| `create_employee` | Create employee record: assign department, supervisor, salary, permissions |
| `update_employee` | Update employee record (title, contact, department transfer, salary adjustment, mark resigned) |
| `search_departments` | Query departments with manager and HRBP info |
| `update_department` | Update department record (change manager or HRBP) |

## 2. recruitment (13 actions)

| Action | Description |
|---|---|
| `search_jds` | Query job descriptions by department, status, or keyword |
| `create_jd` | Create JD record (salary range = monthly x 16, HRBP as contact) |
| `update_jd` | Update JD content or set status to Closed |
| `search_candidates` | Query candidates by name, email, or status |
| `create_candidate` | Create candidate record with resume |
| `update_candidate` | Update candidate record (status, resume, contact info) |
| `search_applications` | Query job applications by status, JD, or candidate |
| `create_application` | Create application record binding candidate to one JD |
| `update_application` | Update application status (Assessing / Interviewing / Negotiating / Accepted / Rejected / Onboarded / Withdrawn) |
| `search_interviews` | Query interview records by application, interviewer, or status |
| `create_interview` | Create interview record and schedule event; assign interviewer per round (R1=supervisor, R2=superior, R3=HRBP) |
| `update_interview` | Update interview record (reschedule, cancel, change interviewer) |
| `submit_interview_feedback` | Record interviewer's score (3.0/3.25/3.5/3.75/4.0) and feedback to interview record |

## 3. schedule (3 actions)

| Action | Description |
|---|---|
| `search_events` | Query events by employee, time range, or status |
| `create_event` | Create a schedule event record |
| `update_event` | Update event time/content or set status to Cancelled |

## 4. okr (4 actions)

| Action | Description |
|---|---|
| `search_okrs` | Query OKR records by employee, year, quarter, or status |
| `create_okr` | Create OKR record with quarterly objectives |
| `submit_okr_review` | Write end-of-quarter review summary to OKR record |
| `submit_okr_rating` | Write performance rating (S/A/B/C) to employee's OKR record |

## 5. salary (1 action)

| Action | Description |
|---|---|
| `get_salary` | Query salary records by employee, year/month, or payout status |

## 6. approval (5 actions)

| Action | Description |
|---|---|
| `search_requests` | Query approval requests (resource + leave, filterable by type and status) |
| `create_resource_request` | Create resource request record (Laptop/Monitor/Mobile/Token); auto-generate approval chain: supervisor -> finance |
| `create_leave_request` | Create leave/overtime request record; system auto-deducts from annual leave / paid sick leave first |
| `handle_approval` | Update approval round status (Approved / Rejected / Canceled) |
| `get_leave_balance` | Query remaining leave days (statutory annual / tenure annual / paid sick) |

## 7. product (3 actions)

| Action | Description |
|---|---|
| `search_products` | Query products by brand, type, price range, stock, or keyword |
| `update_product` | Update product record (price, stock quantity, special-offer flag, returnable flag) |
| `get_manufacturer` | Retrieve manufacturer contact info for warranty referral |

## 8. customer (3 actions)

| Action | Description |
|---|---|
| `search_customers` | Query customers by name, email, phone, or membership tier |
| `create_customer` | Create customer account record |
| `update_customer` | Update customer record; recalculate membership tier from past-6-month completed-order spend |

## 9. order (7 actions)

| Action | Description |
|---|---|
| `search_orders` | Query orders by customer, status, or time range |
| `confirm_payment` | Match incoming bank transfer to order; update payment and order status |
| `cancel_order` | Update order status to Canceled |
| `confirm_receipt` | Update order status to Completed; add product spend to membership accumulation |
| `request_refund` | Create refund request record (7-day no-reason / 14-day quality issue from delivery date) |
| `submit_return_inspect` | Record warehouse inspection result (pass/fail with notes) |
| `handle_refund` | Call payment API to issue refund to original payment method |

## 10. ticket (4 actions)

| Action | Description |
|---|---|
| `search_tickets` | Query tickets by customer, order, type, status, or priority |
| `create_ticket` | Create ticket record ( Order / Logistics / Complaint / System_Issue ) |
| `update_ticket` | Assign handler, update ticket status and priority |
| `submit_ticket_response` | Write customer-service response to ticket record and set status to Resolved |

## 11. email (6 actions)

| Action | Description |
|---|---|
| `search_emails` | Query emails by sender, receiver, subject, or time |
| `list_emails` | Get paginated email list for a mailbox |
| `read_email` | Retrieve full email content by ID |
| `send_email` | Call email API to send message with optional CC |
| `forward_email` | Forward an email to new recipients |
| `reply_email` | Reply to an email (reply-to or reply-all) |

## 12. document (4 actions)

| Action | Description |
|---|---|
| `search_docs` | Query documents by title, tags, type (Internal/External), or status |
| `list_docs` | Get paginated document list (filterable by type and status) |
| `read_doc` | Retrieve full document content by ID |
| `create_doc` | Create and publish document record (Internal for staff, External for customers) |


## 13. bash (1 action)

| Action | Description |
|---|---|
| `execute` | Run a shell command and return stdout/stderr output; supports calculations, data lookups, and scripting |
