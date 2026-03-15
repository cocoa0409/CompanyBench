# Task 1: Submit Interview Feedback and Advance to Next Round

## Metadata

| Property | Value |
|----------|-------|
| Difficulty | Hard |
| Tags | `multi-step` `conditional-logic` `cross-system` `information-retrieval` `implicit-intent` |
| Required Tools | `document` (search_docs, read_doc) · `recruitment` (search_interviews, search_applications, search_candidates, submit_interview_feedback, create_interview) · `employee` (search_employees, search_departments) · `schedule` (search_events) · `email` (send_email) · `bash` (execute) |

## Difficulty Analysis

This task requires the Agent to complete an end-to-end interview advancement workflow for multiple candidates. The key challenges are as follows:

1. **Implicit Intent Resolution**: The user's instruction is highly colloquial — "yesterday's two candidates" provides no names, and "Sarah's feedback document" provides no document ID. The Agent must use the current user identity (Sarah Chen) and temporal context (yesterday) to reverse-query interview records to identify the two candidates, then locate the corresponding feedback document in the document system. This requires the Agent to decompose multiple implicit query conditions from a vague instruction and progressively converge to definite entities.

2. **Proactive Policy Retrieval**: The critical business rules governing the recruitment workflow (interview round definitions, fast-track trigger conditions, interviewer role assignments per round, scoring formulas, etc.) are not inlined in the system prompt but referenced via `doc_id` pointing to external policy documents. The system prompt provides only a policy directory index. The Agent must recognize that the current task belongs to the recruitment domain and proactively retrieve the corresponding recruitment policy document to obtain the specific rules. If the Agent skips this step or relies solely on the behavioral guidelines in the system prompt, it will be unable to determine the fast-track average score threshold or the interviewer assignment rules for each round, causing all subsequent workflow decisions to be entirely incorrect.

3. **Long-Chain Sequential Execution**: The processing workflow for each candidate comprises six strictly ordered steps — submit feedback, query historical scores and compute the overall average, determine the next round based on policy, query the designated interviewer's calendar for the next day's earliest available slot, create an interview record linked to a calendar event, and decide whether to send a notification email based on the round type. Strong data dependencies exist across all six steps: the score from feedback submission feeds into the average calculation; the average determines the next round and interviewer assignment; the interviewer assignment determines whose calendar to query; the calendar query result determines the interview time; and the meeting link returned by interview creation must be included in the notification email body. A single task involves interactions across four subsystems — documents, interviews, schedules, and emails — requiring the Agent to correctly pass contextual information between tool calls across different systems. Any intermediate step that errors, is omitted, or suffers a context propagation break will cause all subsequent steps to deviate from expectations.

4. **Conditional Branching**: Although both candidates are triggered by the same user instruction, their different overall averages lead to entirely different workflow branches. Evelyn Hart's average of 3.375 does not meet the fast-track threshold, so she proceeds through the standard flow to Round 3 (HRBP interview); Arjun Mehta's average of 3.875 exceeds the threshold, triggering the fast track to skip Round 3 and proceed directly to Round 4 (compensation negotiation). The two branches differ in interviewer assignment, calendar query target, and whether a notification email should be sent. The Agent must execute independent conditional judgments for each candidate rather than applying a uniform template.

5. **Multi-Source Constraint Merging**: The business constraints for this task are distributed across three distinct sources — the behavioral guidelines section of the system prompt specifies operational norms such as email subject format templates and recipient/CC rules; the external recruitment policy document specifies business-level rules such as interview round progression, fast-track conditions, and interviewer roles per round; and the user instruction itself implies the temporal constraint "schedule the earliest available slot tomorrow." The Agent must simultaneously perceive and merge constraints from all three sources, ensuring no violation at any execution step. This includes negative constraints — the system prompt explicitly states that "Round 4 (compensation negotiation) does not require a summary email." When processing the fast-track candidate, the Agent must proactively identify the current round and skip the email sending step, rather than mechanically executing the full workflow template for all candidates.

6. **Information Aggregation and Generation**: The Round 3 interview notification email body requires the Agent to aggregate information from multiple systems into a single structured document — the interview time and meeting link come from the interview creation return value, the candidate's resume summary comes from the candidate profile, the first two rounds' feedback and scores come from historical interview records, and the suggested focus areas for Round 3 require the Agent to perform inductive reasoning based on prior round feedback. This demands cross-datasource information integration capability and the ability to transform raw data into structured analytical text targeted at a specific reader (the HRBP interviewer).

## Input

### Session Context

```
Current User Type: Employee
Current User Name: Sarah Chen
Current User ID: employee-f34162ef-cb52-4a65-b079-ff51bd260f59
Current User AK: AAAAC3NzaC1lZDI1NTE5AAAAIKNZRnm0NgZji+ZaMuFdcTrwO8jJtBfZF4SBkksBfaoQ
```

### Prompt

```
Current Time: 2026-03-15 14:30:45

Both candidates from yesterday were solid. I've already written up my interview notes and evaluations in Sarah's feedback doc — go ahead and submit the feedback, then move them along to the next round. Just book the next interviewer's earliest open slot tomorrow, ASAP.
```

## Rubrics

| # | Domain | Method | Criterion | Test Code |
|---|--------|--------|-----------|-----------|
| 1 | response | llm_judge | Response correctly identifies Evelyn Hart as one of the two candidates and associates her with the Database Engineer position in the Engineering department | — |
| 2 | database | unittest | Evelyn Hart's Round 2 interview feedback has been correctly submitted with a score of 3.25 and non-empty feedback content | See `test_evelyn_r2_interview_submitted` |
| 3 | database | extract_judge | Extract the feedback field from Evelyn Hart's Round 2 interview record. Content should faithfully reflect the original feedback document: **Discussion** — (1) Large-scale MySQL→PostgreSQL migration plan (data consistency validation, canary switchover, rollback contingency) (2) Cross-shard transactions under Citus sharding vs. streaming replication RPO/RTO trade-offs (3) Index optimization, query plan analysis, vacuum tuning performance SOP (4) Simulated communication scenario presenting to non-technical executives. **Strengths** — (1) Deep PostgreSQL internals knowledge, identifying bottlenecks at the WAL/storage engine/vacuum mechanism level (2) Solid Citus sharding hands-on experience, clearly articulating shard key and secondary index trade-offs (3) Thorough migration plan: checksum + shadow traffic dual-write validation, canary with traffic percentage and monitoring metrics, rollback with time window constraints. **Weaknesses** — (1) Limited experience with cloud-native solutions (CockroachDB/TiDB/Spanner) (2) Verbose executive presentation, spent 8 minutes on WAL details without leading with conclusions (3) Insufficient understanding of NoSQL hybrid persistence architectures. Score: 3.25 | See `extract_evelyn_r2_feedback` |
| 4 | response | llm_judge | Response should contain the following information: (1) Evelyn Hart's interview scores per round — Round 1 score 3.50, Round 2 score 3.25; (2) current overall average is 3.375; (3) average does not meet fast-track threshold (≤3.75), fast-track conditions not satisfied; (4) per standard process, next round is Round 3 (HRBP interview); (5) Round 3 interviewer is David O'Connell | — |
| 5 | response | llm_judge | Response correctly states that David O'Connell's earliest available working slot on 2026-03-16 is 2026-03-16 11:00:00 to 2026-03-16 12:00:00 | — |
| 6 | database | unittest | A Round 3 interview has been scheduled for Evelyn Hart from 2026-03-16 11:00:00 to 2026-03-16 12:00:00, with no conflict against David O'Connell's existing schedule on that day | See `test_evelyn_r3_interview_scheduled` |
| 7 | database | unittest | An interview notification email has been sent from career@mollydigital.com to davidocon@mollydigital.com with subject "Interview Scheduled: 2026-03-16 11:00:00 - Evelyn Hart for Database Engineer (Engineering) Round 3" | See `test_evelyn_r3_notification_email_sent` |
| 8 | database | extract_judge | Extract the body_content field from the Evelyn Hart Round 3 interview notification email sent from career@mollydigital.com to davidocon@mollydigital.com. Content should include: **(1) Interview time and meeting link** — explicitly stating 2026-03-16 11:00:00 to 2026-03-16 12:00:00 and the meeting link https://meet.mollydigital.com/v1/interview/auth?room_id=MD-7729-XJ9L. **(2) Resume summary** — 5 years of database experience, PostgreSQL/MySQL expertise, DataVault 8TB cluster management and Citus 500M-row sharding, CloudBase AWS RDS + GCP Cloud SQL multi-cloud operations, Stanford CS Master's. **(3) Round 1 feedback (Robert Fischer, 3.50)** — customer_id hash sharding approach is practical, PostgreSQL internals understanding is solid (vacuum/WAL), migration methodology is robust (shadow traffic validation); weaknesses: cascade failure protection is overly theoretical, unfamiliar with next-generation distributed SQL. **(4) Round 2 feedback (Sarah Chen, 3.25)** — strong WAL/storage engine/vacuum-level analytical capability, solid Citus sharding hands-on experience, migration plan includes checksum + shadow traffic validation; weaknesses: limited cloud-native experience, spent 8 minutes on WAL details without leading with conclusions in executive presentation, insufficient NoSQL hybrid architecture understanding. **(5) Round 3 HRBP focus area recommendations** — the first two rounds have thoroughly assessed technical depth; this round should focus on cultural and values alignment, cross-team collaboration and communication style improvement (echoing the "verbose presentation" noted in Round 2), career development plans and stability, willingness to learn cloud-native technologies, and team integration expectations. | See `extract_evelyn_r3_notification_email_body` |
| 9 | response | llm_judge | Response correctly identifies Arjun Mehta as one of the two candidates and associates him with the ML Researcher position in the Algorithm department | — |
| 10 | database | unittest | Arjun Mehta's Round 2 interview feedback has been correctly submitted with a score of 3.75 and non-empty feedback content | See `test_arjun_r2_interview_submitted` |
| 11 | database | extract_judge | Extract the feedback field from Arjun Mehta's Round 2 interview record. Content should faithfully reflect the original feedback document: **Discussion** — (1) Full pipeline from recommendation system research to production: DeepRec transformer model from paper to 10M+ users, including model compression, online serving architecture, canary deployment (2) DeepSpeed ZeRO-3 training optimization on a 64-GPU cluster (72h→18h) (3) A/B testing framework supporting 200+ concurrent experiments with Bayesian early-stopping (4) Forward-looking LLM applications in recommendation systems vs. product delivery balance. **Strengths** — (1) Top-tier publication output (6 papers in 4 years, NeurIPS spotlight/ICML/KDD) (2) Strong theory-to-practice translation, driving 18% CTR improvement and 12% revenue growth (3) Forward-looking vision on LLM-enhanced recommendation explainability and cold-start aligns with platform direction. **Weaknesses** — (1) Weak on engineering practices, SLA/degradation/monitoring remains conceptual, lacking hands-on experience under p99<50ms constraints (2) Accustomed to a two-week experiment cadence, needs to adapt to product team's two-day hotfix pace (3) Took considerable time to propose a compromise solution when pressed on "simplified plan within three days." Score: 3.75 | See `extract_arjun_r2_feedback` |
| 12 | response | llm_judge | Response should contain the following information: (1) Arjun Mehta's interview scores per round — Round 1 score 4.00, Round 2 score 3.75; (2) current overall average is 3.875; (3) average exceeds 3.75, triggering fast track; (4) skip Round 3 (HRBP interview), next round proceeds directly to Round 4 (compensation negotiation); (5) Round 4 interviewer is Emily Watson (HR Director) | — |
| 13 | response | llm_judge | Response correctly states that Emily Watson's earliest available working slot on 2026-03-16 is 2026-03-16 15:30:00 to 2026-03-16 16:30:00 | — |
| 14 | database | unittest | A Round 4 interview (skipping Round 3) has been scheduled for Arjun Mehta from 2026-03-16 15:30:00 to 2026-03-16 16:30:00, with no conflict against Emily Watson's existing schedule on that day | See `test_arjun_r4_interview_scheduled` |
| 15 | database | unittest | No interview notification email was sent to Emily Watson, as Round 4 (compensation negotiation) does not require a summary email | See `test_arjun_r4_no_notification_email` |
| 16 | response | llm_judge | Response provides a complete execution summary for both Evelyn Hart and Arjun Mehta covering: feedback submission results (with scores), next round arrangement (time + interviewer), email sending status, and fast-track trigger explanation | — |

## Test Code

```python
import pytest

# ── Known IDs (determined at environment initialization) ──
EVELYN_R2_INTERVIEW_ID       = "interview-0204463c-4ad1-4503-9c93-468bd232509b"
ARJUN_R2_INTERVIEW_ID        = "interview-8b3f7a2e-6d19-4c5a-b8e1-9f2d4a7c3e6b"
EVELYN_APPLICATION_ID        = "application-107fae94-8808-4bed-ac13-86c7b15221df"
ARJUN_APPLICATION_ID         = "application-a3e5c891-7b24-4f68-9d12-6e8b3f5a2c47"
DAVID_OCONNELL_EMPLOYEE_ID   = "employee-6f753238-3217-4747-a397-2f7989bb660e"
EMILY_WATSON_EMPLOYEE_ID     = "employee-6631e5a0-28c3-44bc-b214-c6477e4093e5"
INITIAL_CAREER_TO_WATSON_EMAIL_COUNT = 0  # Email count from career@ to watson@ at environment initialization


# ── #2 Evelyn Hart Round 2 interview feedback submission ──
def test_evelyn_r2_interview_submitted(db):
    row = db.fetch_one(
        f"SELECT interview_status, score, feedback "
        f"FROM interview WHERE interview_id = '{EVELYN_R2_INTERVIEW_ID}'"
    )
    assert row is not None, "Evelyn Hart Round 2 interview record does not exist"
    assert row["interview_status"] == "Completed", (
        f"Status should be Completed, actual: {row['interview_status']}"
    )
    assert float(row["score"]) == 3.25, (
        f"Score should be 3.25, actual: {row['score']}"
    )
    assert row["feedback"] and row["feedback"].strip(), "Feedback field is empty"


# ── #3 Extract Evelyn Hart Round 2 interview feedback ──
def extract_evelyn_r2_feedback(db):
    row = db.fetch_one(
        f"SELECT feedback FROM interview "
        f"WHERE interview_id = '{EVELYN_R2_INTERVIEW_ID}'"
    )
    assert row is not None and row["feedback"]
    return row["feedback"]


# ── #6 Evelyn Hart Round 3 interview record creation ──
def test_evelyn_r3_interview_scheduled(db):
    row = db.fetch_one(
        f"SELECT interview_id, interview_status, schedule_id "
        f"FROM interview "
        f"WHERE job_application_id = '{EVELYN_APPLICATION_ID}' "
        f"  AND interviewer_employee_id = '{DAVID_OCONNELL_EMPLOYEE_ID}'"
    )
    assert row is not None, "Evelyn Hart Round 3 interview record hosted by David O'Connell not found"
    assert row["interview_status"] == "Scheduled"

    schedule = db.fetch_one(
        f"SELECT start_datetime, end_datetime "
        f"FROM schedule WHERE schedule_id = '{row['schedule_id']}'"
    )
    assert schedule is not None, "Associated calendar event does not exist"
    assert str(schedule["start_datetime"]) == "2026-03-16 11:00:00", (
        f"Start time should be 11:00, actual: {schedule['start_datetime']}"
    )
    assert str(schedule["end_datetime"]) == "2026-03-16 12:00:00", (
        f"End time should be 12:00, actual: {schedule['end_datetime']}"
    )


# ── #7 Interviewer notification email ──
def test_evelyn_r3_notification_email_sent(db):
    row = db.fetch_one(
        f"SELECT email_id, subject FROM email "
        f"WHERE sender_email = 'career@mollydigital.com' "
        f"  AND receiver_email = 'davidocon@mollydigital.com' "
        f"ORDER BY created_at DESC LIMIT 1"
    )
    assert row is not None, "No email found from career@ to davidocon@"
    expected_subject = (
        "Interview Scheduled: 2026-03-16 11:00 - "
        "Evelyn Hart for Database Engineer (Engineering) Round 3"
    )
    assert expected_subject in row["subject"] or row["subject"] == expected_subject, (
        f"Email subject mismatch, actual: {row['subject']}"
    )


# ── #8 Extract notification email body ──
def extract_evelyn_r3_notification_email_body(db):
    row = db.fetch_one(
        f"SELECT body_content FROM email "
        f"WHERE sender_email = 'career@mollydigital.com' "
        f"  AND receiver_email = 'davidocon@mollydigital.com' "
        f"ORDER BY created_at DESC LIMIT 1"
    )
    assert row is not None and row["body_content"]
    return row["body_content"]


# ── #10 Arjun Mehta Round 2 interview feedback submission ──
def test_arjun_r2_interview_submitted(db):
    row = db.fetch_one(
        f"SELECT interview_status, score, feedback "
        f"FROM interview WHERE interview_id = '{ARJUN_R2_INTERVIEW_ID}'"
    )
    assert row is not None, "Arjun Mehta Round 2 interview record does not exist"
    assert row["interview_status"] == "Completed", (
        f"Status should be Completed, actual: {row['interview_status']}"
    )
    assert float(row["score"]) == 3.75, (
        f"Score should be 3.75, actual: {row['score']}"
    )
    assert row["feedback"] and row["feedback"].strip(), "Feedback field is empty"


# ── #11 Extract Arjun Mehta Round 2 interview feedback ──
def extract_arjun_r2_feedback(db):
    row = db.fetch_one(
        f"SELECT feedback FROM interview "
        f"WHERE interview_id = '{ARJUN_R2_INTERVIEW_ID}'"
    )
    assert row is not None and row["feedback"]
    return row["feedback"]


# ── #14 Arjun Mehta Round 4 interview record creation ──
def test_arjun_r4_interview_scheduled(db):
    row = db.fetch_one(
        f"SELECT interview_id, interview_status, schedule_id "
        f"FROM interview "
        f"WHERE job_application_id = '{ARJUN_APPLICATION_ID}' "
        f"  AND interviewer_employee_id = '{EMILY_WATSON_EMPLOYEE_ID}'"
    )
    assert row is not None, "Arjun Mehta Round 4 interview record hosted by Emily Watson not found"
    assert row["interview_status"] == "Scheduled"

    schedule = db.fetch_one(
        f"SELECT start_datetime, end_datetime "
        f"FROM schedule WHERE schedule_id = '{row['schedule_id']}'"
    )
    assert schedule is not None, "Associated calendar event does not exist"
    assert str(schedule["start_datetime"]) == "2026-03-16 15:30:00", (
        f"Start time should be 15:30, actual: {schedule['start_datetime']}"
    )
    assert str(schedule["end_datetime"]) == "2026-03-16 16:30:00", (
        f"End time should be 16:30, actual: {schedule['end_datetime']}"
    )


# ── #15 No interview notification email should exist for Emily Watson ──
def test_arjun_r4_no_notification_email(db):
    row = db.fetch_one(
        f"SELECT COUNT(*) AS cnt FROM email "
        f"WHERE sender_email = 'career@mollydigital.com' "
        f"  AND receiver_email = 'watson@mollydigital.com'"
    )
    assert row["cnt"] == INITIAL_CAREER_TO_WATSON_EMAIL_COUNT, (
        f"No notification email should be sent for Round 4 compensation negotiation, "
        f"initial count: {INITIAL_CAREER_TO_WATSON_EMAIL_COUNT}, current: {row['cnt']}"
    )
```
