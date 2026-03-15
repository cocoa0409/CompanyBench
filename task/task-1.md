# Task 1: 提交面评并推进下一轮面试

## Metadata

| 属性 | 值 |
|------|-----|
| 难度 | Hard |
| 标签 | `multi-step` `conditional-logic` `cross-system` `information-retrieval` `implicit-intent`|
| 依赖工具 | `document`（search_docs, read_doc）· `recruitment`（search_interviews, search_applications, search_candidates, submit_interview_feedback, create_interview）· `employee`（search_employees, search_departments）· `schedule`（search_events）· `email`（send_email）· `bash`（execute） |

## 难度说明

本题要求 Agent 完成一次端到端的多候选人面试推进流程，难度主要体现在以下几个方面：

1. **隐式意图解析**：用户的指令高度口语化——"昨天的两位候选人"未给出姓名，"Sarah面评文档"未给出文档 ID。Agent 需要根据当前用户身份（Sarah Chen）和时间上下文（昨天），反向查询面试记录以锁定两位候选人的身份，再从文档系统中定位到对应的面评文档。整个过程要求 Agent 从模糊指令中拆解出多个隐式查询条件，并逐步收敛到确定实体。

2. **政策主动检索**：招聘流程的关键业务规则（面试轮次定义、快速通道触发条件、各轮面试官角色分配、评分计算方式等）并未内联在 system prompt 中，而是以 `doc_id` 引用的形式指向外部政策文档。System prompt 仅提供了政策目录索引，Agent 必须识别当前任务所属的业务域（招聘管理），主动检索对应的招聘政策文档以获取具体规则。如果 Agent 跳过这一步或仅依赖 system prompt 中的行为指引，将无法得知快速通道的均分阈值以及各轮面试官的确定规则，从而导致后续流程判断完全错误。

3. **长链路串行执行**：每位候选人的处理流程包含六个严格依序的步骤——提交面评、查询历史评分并计算综合均分、依据政策判定下一轮走向、查询指定面试官次日的日程空闲时段、创建面试记录并关联日程、根据轮次决定是否发送通知邮件。六个步骤之间存在强数据依赖：面评提交后的评分用于均分计算，均分决定下一轮轮次和面试官人选，面试官人选决定需查询哪位员工的日程，日程查询结果决定面试的具体时间，面试创建的返回值（会议链接）需写入通知邮件正文。单次任务涉及文档、面试、日程、邮件四个子系统的交互，Agent 需要在不同系统的工具调用之间正确传递上下文信息。任一中间步骤出错、遗漏或信息传递断裂，后续步骤将全部偏离预期。

4. **条件分支处理**：两位候选人虽然由同一条用户指令触发，但因综合均分不同而走向完全不同的流程分支。Evelyn Hart 均分 3.375 未达到快速通道阈值，按标准流程进入第三轮 HRBP 面试；Arjun Mehta 均分 3.875 超过阈值，触发快速通道跳过第三轮直接进入第四轮薪酬谈判。两条分支在面试官人选、日程查询对象、是否发送通知邮件等方面均存在差异。Agent 需要对每位候选人独立执行条件判断，而非套用统一模板。

5. **多源约束归并**：本题涉及的业务约束分散在三个不同来源中——system prompt 的行为指引章节规定了邮件主题格式模板、收件人/抄送规则等操作层面的规范；外部招聘政策文档规定了面试轮次流转规则、快速通道条件、各轮面试官角色等业务层面的规则；用户指令本身隐含了"安排明天最早空闲时间"的时间约束。Agent 需要同时感知并归并这三处来源的约束条件，在执行每一步操作时确保不违反任何一处的规定。其中还包含负向约束——system prompt 明确规定"第四轮薪酬谈判不需要发送 summary email"，Agent 在处理触发快速通道的候选人时需主动识别当前轮次并跳过邮件发送，而非对所有候选人机械地执行完整流程模板。

6. **信息聚合生成**：第三轮面试通知邮件的正文要求 Agent 将来自多个系统的信息聚合为一份结构化文档——面试时间和会议链接来自面试创建的返回值，候选人简历摘要来自候选人档案，前两轮的面试反馈和评分来自历史面试记录，第三轮的关注维度建议需要 Agent 基于前两轮反馈进行归纳推理。这要求 Agent 具备跨数据源的信息整合能力，以及将原始数据转化为面向特定读者（HRBP 面试官）的结构化分析文本的生成能力。

## Input

### Session Context

```
Current User Type: Employee
Current User Name: Sarah Chen
Current User ID: employee-f34162ef-cb52-4a65-b079-ff51bd260f59
```

### Prompt

```
Current Time: 2026-03-15 14:30:45

昨天的两位候选人都不错，面试记录和评价我都记在Sarah面评文档了，请帮我提交面评，并推进他们的下一轮面试，直接安排下一轮面试官明天最早的空闲时间就行，尽快
```

## Rubrics

| # | 检查域 | 检查方法 | 检查项 | 测试代码 |
|---|--------|---------|--------|---------|
| 1 | response | llm_judge | 回复正确识别出 Evelyn Hart 为两位候选人之一，并关联到 Engineering 部门 Database Engineer 岗位 | — |
| 2 | database | unittest | Evelyn Hart 的第二轮面评已正确提交，评分为 3.25，面试反馈内容不为空 | 见 `test_evelyn_r2_interview_submitted` |
| 3 | database | extract_judge | 提取 Evelyn Hart 第二轮面试记录的 feedback 字段，内容应忠实反映面评文档原文：**讨论**——(1) MySQL→PostgreSQL 大规模迁移方案（数据一致性验证、灰度切换、回滚预案）(2) Citus 分片下跨分片事务与 streaming replication RPO/RTO 权衡 (3) 索引优化、查询计划分析、vacuum 调参的性能调优 SOP (4) 模拟向非技术高管汇报的沟通场景。**优点**——(1) PostgreSQL 内核深入，从 WAL/存储引擎/vacuum 机制层面定位瓶颈 (2) Citus 分片实操扎实，清晰表达分片键与二级索引 trade-off (3) 迁移方案周全：checksum+shadow traffic 双写验证，灰度有流量百分比和监控指标，回滚有时间窗口约束。**不足**——(1) 云原生方案（CockroachDB/TiDB/Spanner）经验有限 (2) 高管汇报表达冗长，花 8 分钟讲 WAL 细节未先给结论 (3) NoSQL 混合持久化架构理解不足。评分 3.25 | 见 `extract_evelyn_r2_feedback` |
| 4 | response | llm_judge | 回复应包含以下信息：(1) Evelyn Hart 各轮面试评分——第一轮得分 3.50、第二轮得分 3.25；(2) 当前综合均分为 3.375；(3) 均分未达到快速通道阈值（≤3.75），不满足快速通道条件；(4) 依据标准流程，下一轮为第三轮（HRBP 面试）；(5) 第三轮面试官为 David O'Connell | — |
| 5 | response | llm_judge | 回复正确说明 David O'Connell 2026-03-16 最早的工作空闲时段为 2026-03-16 11:00:00 至 2026-03-16 12:00:00 | — |
| 6 | database | unittest | 已为 Evelyn Hart 安排第三轮面试，时间为 2026-03-16 11:00:00 至 2026-03-16 12:00:00，未与 David O'Connell 当天已有日程冲突 | 见 `test_evelyn_r3_interview_scheduled` |
| 7 | database | unittest | 已通过 career@mollydigital.com 向 davidocon@mollydigital.com 发送面试通知邮件，标题为 "Interview Scheduled: 2026-03-16 11:00:00 - Evelyn Hart for Database Engineer (Engineering) Round 3" | 见 `test_evelyn_r3_notification_email_sent` |
| 8 | database | extract_judge | 提取 career@mollydigital.com 发送给 davidocon@mollydigital.com 的 Evelyn Hart 第三轮面试通知邮件的 body_content 字段，内容应包含：**(1) 面试时间与会议链接**——明确写出 2026-03-16 11:00:00 至 2026-03-16 12:00:00 及面试链接 https://meet.mollydigital.com/v1/interview/auth?room_id=MD-7729-XJ9L。**(2) 简历摘要**——5 年数据库经验、PostgreSQL/MySQL 专长、DataVault 8TB 集群管理和 Citus 500M 行分片、CloudBase AWS RDS + GCP Cloud SQL 多云运维、Stanford CS 硕士。**(3) 第一轮反馈（Robert Fischer, 3.50）**——customer_id hash 分片思路实际、PostgreSQL 内核理解到位（vacuum/WAL）、迁移方法论扎实（shadow traffic 验证）；不足：级联故障防护偏理论化、对新一代分布式 SQL 不熟悉。**(4) 第二轮反馈（Sarah Chen, 3.25）**——WAL/存储引擎/vacuum 层面分析能力强、Citus 分片实操扎实、迁移方案含 checksum+shadow traffic 验证；不足：云原生经验有限、高管汇报花 8 分钟讲 WAL 细节未先给结论、NoSQL 混合架构理解不足。**(5) 第三轮 HRBP 关注维度建议**——前两轮已充分考察技术深度，本轮应侧重文化价值观契合度、跨部门协作与沟通风格改善空间（呼应第二轮指出的"表达冗长"）、职业发展规划与稳定性、对云原生新技术的学习意愿、团队融入预期； | 见 `extract_evelyn_r3_notification_email_body` |
| 9 | response | llm_judge | 回复正确识别出 Arjun Mehta 为两位候选人之一，关联到 Algorithm 部门 ML Researcher 岗位 | — |
| 10 | database | unittest | Arjun Mehta 的第二轮面评已正确提交，评分为 3.75，面试反馈内容不为空 | 见 `test_arjun_r2_interview_submitted` |
| 11 | database | extract_judge | 提取 Arjun Mehta 第二轮面试记录的 feedback 字段，内容应忠实反映面评文档原文：**讨论**——(1) 推荐系统研究到生产完整链路：DeepRec transformer 模型从论文到 10M+ 用户，含模型压缩、在线服务架构、灰度上线 (2) DeepSpeed ZeRO-3 在 64 卡集群训练优化（72h→18h）(3) 支持 200+ 并发实验的 A/B 测试框架及 Bayesian early-stopping (4) LLM 在推荐系统中的前瞻应用 vs 产品交付平衡。**优点**——(1) 顶会论文产出顶尖（4 年 6 篇，NeurIPS spotlight/ICML/KDD）(2) 理论到实践转化强，推动 18% CTR 提升和 12% 收入增长 (3) LLM 增强推荐解释性和冷启动的前瞻性与平台方向契合。**不足**——(1) 工程化偏弱，SLA/降级/监控停留概念层面，缺少 p99<50ms 约束下实操 (2) 习惯两周一实验节奏，产品团队两天出 hotfix 需适应 (3) 追问"三天内简化方案"思考较长才给妥协方案。评分 3.75 | 见 `extract_arjun_r2_feedback` |
| 12 | response | llm_judge | 回复应包含以下信息：(1) Arjun Mehta 各轮面试评分——第一轮得分 4.00、第二轮得分 3.75；(2) 当前综合均分为 3.875；(3) 均分超过 3.75，触发快速通道；(4) 跳过第三轮（HRBP 面试），下一轮直接进入第四轮（薪酬谈判）；(5) 第四轮面试官为 Emily Watson（HR 主管） | — |
| 13 | response | llm_judge | 回复正确说明 Emily Watson 2026-03-16 最早的工作空闲时段为 2026-03-16 15:30:00 至 2026-03-16 16:30:00 | — |
| 14 | database | unittest | 已为 Arjun Mehta 安排第四轮面试（跳过第三轮），时间为 2026-03-16 15:30:00 至 2026-03-16 16:30:00，未与 Emily Watson 当天已有日程冲突 | 见 `test_arjun_r4_interview_scheduled` |
| 15 | database | unittest | 未向 Emily Watson 发送面试通知邮件，因为第四轮薪酬谈判不需要 summary email | 见 `test_arjun_r4_no_notification_email` |
| 16 | response | llm_judge | 回复对 Evelyn Hart 和 Arjun Mehta 的面试安排均给出完整执行摘要：面评提交结果（含评分）、下一轮安排（时间+面试官）、邮件发送情况、快速通道触发说明 | — |

## Test Code

```python
import pytest

# ── 已知 ID（环境初始化时确定） ──
EVELYN_R2_INTERVIEW_ID       = "interview-0204463c-4ad1-4503-9c93-468bd232509b"
ARJUN_R2_INTERVIEW_ID        = "interview-8b3f7a2e-6d19-4c5a-b8e1-9f2d4a7c3e6b"
EVELYN_APPLICATION_ID        = "application-107fae94-8808-4bed-ac13-86c7b15221df"
ARJUN_APPLICATION_ID         = "application-a3e5c891-7b24-4f68-9d12-6e8b3f5a2c47"
DAVID_OCONNELL_EMPLOYEE_ID   = "employee-6f753238-3217-4747-a397-2f7989bb660e"
EMILY_WATSON_EMPLOYEE_ID     = "employee-6631e5a0-28c3-44bc-b214-c6477e4093e5"
INITIAL_CAREER_TO_WATSON_EMAIL_COUNT = 0  # 环境初始化时 career@ 发给 watson@ 的邮件数量


# ── #2 Evelyn Hart 第二轮面试记录提交 ──
def test_evelyn_r2_interview_submitted(db):
    row = db.fetch_one(
        f"SELECT interview_status, score, feedback "
        f"FROM interview WHERE interview_id = '{EVELYN_R2_INTERVIEW_ID}'"
    )
    assert row is not None, "Evelyn Hart 第二轮面试记录不存在"
    assert row["interview_status"] == "Completed", (
        f"状态应为 Completed，实际为 {row['interview_status']}"
    )
    assert float(row["score"]) == 3.25, (
        f"评分应为 3.25，实际为 {row['score']}"
    )
    assert row["feedback"] and row["feedback"].strip(), "feedback 字段为空"


# ── #3 提取 Evelyn Hart 第二轮面试反馈 ──
def extract_evelyn_r2_feedback(db):
    row = db.fetch_one(
        f"SELECT feedback FROM interview "
        f"WHERE interview_id = '{EVELYN_R2_INTERVIEW_ID}'"
    )
    assert row is not None and row["feedback"]
    return row["feedback"]


# ── #6 Evelyn Hart 第三轮面试记录与日程创建 ──
def test_evelyn_r3_interview_scheduled(db):
    row = db.fetch_one(
        f"SELECT interview_id, interview_status, schedule_id "
        f"FROM interview "
        f"WHERE job_application_id = '{EVELYN_APPLICATION_ID}' "
        f"  AND interviewer_employee_id = '{DAVID_OCONNELL_EMPLOYEE_ID}'"
    )
    assert row is not None, "未找到 Evelyn Hart 由 David O'Connell 主持的第三轮面试记录"
    assert row["interview_status"] == "Scheduled"

    schedule = db.fetch_one(
        f"SELECT start_datetime, end_datetime "
        f"FROM schedule WHERE schedule_id = '{row['schedule_id']}'"
    )
    assert schedule is not None, "关联的日程事件不存在"
    assert str(schedule["start_datetime"]) == "2026-03-16 11:00:00", (
        f"开始时间应为 11:00，实际为 {schedule['start_datetime']}"
    )
    assert str(schedule["end_datetime"]) == "2026-03-16 12:00:00", (
        f"结束时间应为 12:00，实际为 {schedule['end_datetime']}"
    )


# ── #7 面试官通知邮件发送 ──
def test_evelyn_r3_notification_email_sent(db):
    row = db.fetch_one(
        f"SELECT email_id, subject FROM email "
        f"WHERE sender_email = 'career@mollydigital.com' "
        f"  AND receiver_email = 'davidocon@mollydigital.com' "
        f"ORDER BY created_at DESC LIMIT 1"
    )
    assert row is not None, "未找到 career@ 发送给 davidocon@ 的邮件"
    expected_subject = (
        "Interview Scheduled: 2026-03-16 11:00 - "
        "Evelyn Hart for Database Engineer (Engineering) Round 3"
    )
    assert expected_subject in row["subject"] or row["subject"] == expected_subject, (
        f"邮件标题不匹配，实际为: {row['subject']}"
    )


# ── #8 提取通知邮件 body 供 LLM judge ──
def extract_evelyn_r3_notification_email_body(db):
    row = db.fetch_one(
        f"SELECT body_content FROM email "
        f"WHERE sender_email = 'career@mollydigital.com' "
        f"  AND receiver_email = 'davidocon@mollydigital.com' "
        f"ORDER BY created_at DESC LIMIT 1"
    )
    assert row is not None and row["body_content"]
    return row["body_content"]


# ── #10 Arjun Mehta 第二轮面试记录提交 ──
def test_arjun_r2_interview_submitted(db):
    row = db.fetch_one(
        f"SELECT interview_status, score, feedback "
        f"FROM interview WHERE interview_id = '{ARJUN_R2_INTERVIEW_ID}'"
    )
    assert row is not None, "Arjun Mehta 第二轮面试记录不存在"
    assert row["interview_status"] == "Completed", (
        f"状态应为 Completed，实际为 {row['interview_status']}"
    )
    assert float(row["score"]) == 3.75, (
        f"评分应为 3.75，实际为 {row['score']}"
    )
    assert row["feedback"] and row["feedback"].strip(), "feedback 字段为空"


# ── #11 提取 Arjun Mehta 第二轮面试反馈 ──
def extract_arjun_r2_feedback(db):
    row = db.fetch_one(
        f"SELECT feedback FROM interview "
        f"WHERE interview_id = '{ARJUN_R2_INTERVIEW_ID}'"
    )
    assert row is not None and row["feedback"]
    return row["feedback"]


# ── #14 Arjun Mehta 第四轮面试记录与日程创建 ──
def test_arjun_r4_interview_scheduled(db):
    row = db.fetch_one(
        f"SELECT interview_id, interview_status, schedule_id "
        f"FROM interview "
        f"WHERE job_application_id = '{ARJUN_APPLICATION_ID}' "
        f"  AND interviewer_employee_id = '{EMILY_WATSON_EMPLOYEE_ID}'"
    )
    assert row is not None, "未找到 Arjun Mehta 由 Emily Watson 主持的第四轮面试记录"
    assert row["interview_status"] == "Scheduled"

    schedule = db.fetch_one(
        f"SELECT start_datetime, end_datetime "
        f"FROM schedule WHERE schedule_id = '{row['schedule_id']}'"
    )
    assert schedule is not None, "关联的日程事件不存在"
    assert str(schedule["start_datetime"]) == "2026-03-16 15:30:00", (
        f"开始时间应为 15:30，实际为 {schedule['start_datetime']}"
    )
    assert str(schedule["end_datetime"]) == "2026-03-16 16:30:00", (
        f"结束时间应为 16:30，实际为 {schedule['end_datetime']}"
    )


# ── #15 不应存在发给 Emily Watson 的面试安排邮件 ──
def test_arjun_r4_no_notification_email(db):
    row = db.fetch_one(
        f"SELECT COUNT(*) AS cnt FROM email "
        f"WHERE sender_email = 'career@mollydigital.com' "
        f"  AND receiver_email = 'watson@mollydigital.com'"
    )
    assert row["cnt"] == INITIAL_CAREER_TO_WATSON_EMAIL_COUNT, (
        f"不应为第四轮薪酬谈判发送通知邮件，"
        f"初始邮件数为 {INITIAL_CAREER_TO_WATSON_EMAIL_COUNT}，当前为 {row['cnt']}"
    )
```
