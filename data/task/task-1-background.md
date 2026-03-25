# Task 1: 提交面评并推进下一轮面试

## 1. Session Context

```
Current User Type: Employee
Current User Name: Sarah Chen
Current User Title: CTO, Chief Technology Officer
Current User Level: L1
Current User ID: employee-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Current Time: 2026-03-15T14:30:45-07:00
```

## 2. Prompt

```
昨天的两位候选人都不错，面试记录和评价我都记在Sarah面评文档了，请帮我提交面评，并推进他们的下一轮面试，直接安排下一轮面试官明天最早的空闲时间就行，尽快
```

## 3. Rubrics

### Ground Truth（初始数据）

#### Evelyn Hart 简历（candidate.resume_content）

```
Evelyn Hart
Email: evelyn.hart@email.com | Phone: (650) 555-1234 | Mountain View, CA

SUMMARY
Database engineer with 5+ years of experience designing, optimizing, and operating large-scale
relational database systems. Deep expertise in PostgreSQL internals, zero-downtime migration,
and high-availability sharding architecture. Track record of managing TB-scale production clusters
with 99.99% uptime SLA across multi-cloud environments.

WORK EXPERIENCE

Senior Database Administrator | DataVault Technologies, San Jose, CA | 2022.06 – 2026.02
- Managed a cluster of 12 PostgreSQL 14 instances handling 8 TB+ transactional data, serving
  2M+ daily active users with p99 read latency < 50 ms
- Led end-to-end migration of the core order processing database from MySQL 5.7 to PostgreSQL 14,
  achieving 40% query throughput improvement with zero downtime; used logical replication combined
  with shadow-traffic validation to guarantee data consistency during the 6-week cutover window
- Designed horizontal sharding strategy using Citus extension, distributing a 500M-row order table
  across 8 shards and reducing p99 write latency from 800 ms to 120 ms
- Built automated health-monitoring pipeline with custom pg_stat_statements extensions, PgBadger
  log analysis, and Grafana alerting dashboards; reduced mean-time-to-recovery from 45 min to 8 min
- Established cross-region disaster recovery with streaming replication (RPO < 1 s, RTO < 5 min),
  successfully validated through quarterly failover drills

Database Engineer | CloudBase Inc., Mountain View, CA | 2020.09 – 2022.05
- Operated 6 AWS RDS PostgreSQL instances and 3 GCP Cloud SQL instances for a multi-cloud SaaS
  platform serving 800K monthly active users
- Implemented PgBouncer connection pooling, scaling concurrent connection capacity from 500 to
  5,000 without hardware upgrade
- Designed master-replica read separation architecture for analytics workloads, offloading 60%
  of read traffic from the primary instance
- Developed ETL pipelines for data warehouse synchronization using PostgreSQL Foreign Data
  Wrappers and logical decoding, processing 20M+ row incremental syncs nightly

EDUCATION
M.S. Computer Science | Stanford University | 2018 – 2020
  Thesis: "Adaptive Query Optimization in Heterogeneous Distributed Database Environments"
B.S. Computer Science | UC Berkeley | 2014 – 2018

SKILLS
Databases: PostgreSQL (expert-level, source-code-reading proficiency), MySQL, Redis, MongoDB
Cloud Platforms: AWS (RDS, Aurora, DynamoDB), GCP (Cloud SQL, Spanner)
Tooling: Citus, PgBouncer, Patroni, pgBackRest, pg_stat_statements, PgBadger
Languages: SQL, Python, Go, Bash
```

#### Arjun Mehta 简历（candidate.resume_content）

```
Arjun Mehta
Email: arjun.mehta@email.com | Phone: (408) 555-5678 | Palo Alto, CA
Google Scholar: scholar.google.com/citations?user=arjunmehta

SUMMARY
Machine learning researcher with 4+ years of experience specializing in recommendation systems
and information retrieval. Published 6 papers at top-tier venues (NeurIPS, ICML, KDD, RecSys).
Proven ability to bridge research and production—deployed transformer-based recommendation models
serving 10M+ users with measurable revenue impact.

WORK EXPERIENCE

Research Scientist | DeepRec AI Lab, Palo Alto, CA | 2023.01 – 2026.01
- Designed and deployed next-generation recommendation engine using transformer-based sequential
  user modeling, improving platform-wide click-through rate by 18% and revenue per session by 12%
  across a user base of 10M+ MAU
- Published "Temporal-Aware Collaborative Filtering with Self-Supervised Pre-training" at
  NeurIPS 2024 as a spotlight paper; proposed a novel contrastive pre-training objective on user
  behavior sequences that reduced cold-start degradation by 35%
- Architected multi-stage A/B testing framework supporting 200+ concurrent experiments with
  automated statistical significance detection, guardrail metrics monitoring, and Bayesian
  early-stopping rules
- Optimized distributed training pipeline on a 64-GPU cluster using DeepSpeed ZeRO Stage-3,
  reducing wall-clock training time for a 1B-parameter retrieval model from 72 h to 18 h
- Mentored 3 junior researchers; co-authored 2 additional publications during mentorship

Research Intern | Google Research, Mountain View, CA | 2022.06 – 2022.12
- Developed multi-task learning framework for search ranking combining relevance, freshness,
  and personalization signals with Pareto-optimal calibration
- Published "Multi-Objective Search Ranking with Pareto-Optimal Calibration" at KDD 2023
- Collaborated with Google Search production team to integrate research prototype into the
  live ranking stack, contributing to a 2.1% improvement in long-click rate

PUBLICATIONS
1. "Temporal-Aware Collaborative Filtering with Self-Supervised Pre-training" — NeurIPS 2024 (Spotlight)
2. "Efficient Large-Scale Recommendation via Mixture-of-Experts Retrieval" — ICML 2025
3. "Multi-Objective Search Ranking with Pareto-Optimal Calibration" — KDD 2023
4. "Feature Interaction Networks for Click-Through Rate Prediction" — RecSys 2023
5. "Debiased Learning-to-Rank with Counterfactual Estimation" — NeurIPS 2023
6. "Cold-Start Recommendation via Meta-Learning on User Behavior Graphs" — ICML 2024

EDUCATION
Ph.D. Computer Science | Carnegie Mellon University | 2020 – 2024
  Thesis: "Scalable and Adaptive Recommendation Systems: From Research to Production"
M.S. Computer Science | Carnegie Mellon University | 2018 – 2020
B.Tech. Computer Science | IIT Bombay | 2014 – 2018

SKILLS
ML Frameworks: PyTorch (expert), TensorFlow, JAX
Recommendation: Two-tower retrieval, multi-task ranking, sequential modeling, cold-start meta-learning
Infrastructure: DeepSpeed, FSDP, Ray, feature stores (Feast/Tecton), Triton Inference Server
Languages: Python, C++, Scala
```

#### R1 已有面试记录（interview 表，status=Completed）

| 字段 | Evelyn Hart R1 | Arjun Mehta R1 |
|------|---------------|----------------|
| interviewer | Robert Fischer (Engineering Manager) | Howard Xu (Algorithm Manager) |
| score | 3.50 | 4.00 |
| feedback | 候选人技术基础扎实。让她设计我们电商订单系统（日均 500 万事务）的分片方案，她基于 customer_id 的 hash 分片思路很实际，二级索引策略也考虑到了按 order_id 反查的场景。PostgreSQL 内核层面的理解到位——准确定位了 vacuum 调优和 WAL 配置对写入吞吐的影响。迁移方法论扎实，shadow traffic 验证的做法说明有真正的生产经验。不足之处：问到 12 节点集群的级联故障防护时，回答偏理论化，缺少实际处理大规模故障的案例。另外对 CockroachDB、TiDB 等新一代分布式 SQL 不太熟悉，而这些可能与我们未来的扩展方向相关。总体推荐，建议后续重点关注高并发场景下的应急处理能力。 | 候选人研究能力出众。深入讨论了他 NeurIPS 2024 spotlight 论文中关于时序感知协同过滤的自监督预训练方法，其对用户行为序列建模的创新思路清晰且有深度。让他从零设计我们相机电商平台的推荐系统，他提出了一个很实际的两阶段 retrieve-then-rank 架构，每个阶段都有具体的模型选型建议。对大语言模型在推荐解释性上的应用有独到的技术前瞻视野。就其职业阶段而言，发表记录非常出色。不足：生产工程经验集中在研究实验室环境，我们的 CI/CD 和部署流水线可能需要一些上手时间。讨论实时特征服务时，对生产级 feature store（如 Feast、Tecton）的模式不太熟悉。强烈建议录用，对团队未来研究方向有很强的推动潜力。 |

#### Sarah 面评文档（document 表，type=Internal）

**doc_id:** doc-sarah-feedback-001
**title:** Sarah Chen 面试评价记录 - 2026年3月14日
**content_body:**

```markdown
# 面试评价记录

## 候选人：Evelyn Hart — Database Engineer (Engineering)

**面试日期：** 2026-03-14 10:00-11:00
**面试轮次：** 第二轮（Leadership Interview）

### 讨论内容
本轮面试围绕数据库架构设计能力和技术领导力展开。重点讨论了以下方面：
1. 大规模数据库迁移方案设计——让她描述从 MySQL 到 PostgreSQL 的完整迁移路径，
   包括数据一致性验证、灰度切换节奏和回滚预案；她以之前 DataVault 的实际项目为例，
   逻辑链条完整
2. 分布式数据库一致性保障策略——追问了 Citus 分片场景下跨分片事务的处理思路，
   以及 streaming replication 的 RPO/RTO 权衡
3. 数据库性能调优方法论——从索引优化、查询计划分析到 vacuum 调参，考察了她面对
   慢查询时的排查 SOP
4. 跨团队协作中的技术沟通能力——模拟了一个需要向非技术高管汇报数据库架构升级
   方案的场景

### 优点
- 对 PostgreSQL 内核有深入理解，能从 WAL、存储引擎、vacuum 机制层面分析性能瓶颈，
  不是停留在使用层面的"调参侠"
- 数据库分片方案设计经验丰富，Citus 实操经验扎实，能清晰表达分片键选择和
  二级索引策略的 trade-off
- 迁移方案考虑周全——数据校验用了 checksum 对比 + shadow traffic 双写验证，
  灰度切换有明确的流量百分比和监控指标，回滚机制有时间窗口约束

### 不足
- 云原生数据库解决方案（CockroachDB、TiDB、Spanner）经验有限，考虑到我们
  未来可能的多云分布式架构方向，这块需要补强
- 技术表达偏冗长——在模拟高管汇报环节，花了 8 分钟讲 WAL 细节而没有先给结论，
  高层沟通场景需要更精炼的 top-down 表达方式
- 对 NoSQL（如 MongoDB、DynamoDB）的应用场景理解不够深入，在问到混合持久化
  架构时显得犹豫

### 评分：3.25（一般）

---

## 候选人：Arjun Mehta — ML Researcher (Algorithm)

**面试日期：** 2026-03-14 14:00-15:00
**面试轮次：** 第二轮（Leadership Interview）

### 讨论内容
本轮面试围绕机器学习研究方法论和工程落地能力展开。重点讨论了以下方面：
1. 推荐系统从研究到生产的完整链路设计——让他描述在 DeepRec 将 transformer-based
   sequential model 从论文原型部署到服务 10M+ 用户的过程，包括模型压缩、
   在线服务架构和灰度上线策略
2. 大规模模型训练的资源优化策略——讨论了 DeepSpeed ZeRO-3 在 64 卡集群上的
   实际调优经验，以及训练时间从 72h 压缩到 18h 的具体优化点
3. A/B 测试框架设计和实验评估方法论——考察了他在 DeepRec 搭建的支持 200+
   并发实验的框架，以及 Bayesian early-stopping 的统计原理
4. 技术前瞻性和对团队研究方向的规划思路——探讨了大模型在推荐系统中的应用前景，
   以及如何平衡研究创新和产品交付

### 优点
- 顶会论文发表记录优秀——NeurIPS spotlight、ICML、KDD 均有发表，4 年 6 篇的
  产出在同龄研究者中属于顶尖水平，研究深度和广度兼备
- 推荐系统理论到实践的转化能力强——不是纯发论文的人，有真正把模型推到线上
  服务千万级用户并产生 18% CTR 提升和 12% 收入增长的实战经验
- 对未来技术趋势有独到见解——关于 LLM 增强推荐解释性和冷启动的思路很有
  前瞻性，跟我们平台的个性化方向高度契合

### 不足
- 工程化经验相对偏弱——在讨论模型服务的 SLA 保障、降级策略和监控告警时，
  回答停留在概念层面，缺少在严格 SLA（如 p99 < 50ms）约束下的实操经验
- 从研究环境切换到产品环境可能需要适应期——他习惯的是两周一个实验的节奏，
  而我们产品团队有时需要两天内出 hotfix
- 在快速迭代场景下，可能过于追求方案的理论完美度而影响交付速度——追问
  "如果只给你三天，你会怎么简化方案"时，思考了较长时间才给出一个妥协方案

### 评分：3.75（非常推荐）
```

#### Sarah Chen 3月14日日程（schedule 表）

| content | start_datetime | end_datetime |
|---------|---------------|-------------|
| Interview: Evelyn Hart - Database Engineer R2 | 2026-03-14 10:00 | 2026-03-14 11:00 |
| Interview: Arjun Mehta - ML Researcher R2 | 2026-03-14 14:00 | 2026-03-14 15:00 |

#### David O'Connell 3月16日日程（schedule 表）

| content | start_datetime | end_datetime |
|---------|---------------|-------------|
| Team sync meeting | 2026-03-16 09:00 | 2026-03-16 10:00 |
| 1:1 with Emily Watson | 2026-03-16 10:00 | 2026-03-16 11:00 |
| Lunch break | 2026-03-16 12:00 | 2026-03-16 13:00 |
| Department HRBP review | 2026-03-16 14:00 | 2026-03-16 15:00 |

**→ 最早工作时间空闲段：11:00–12:00**

#### Emily Watson 3月16日日程（schedule 表）

| content | start_datetime | end_datetime |
|---------|---------------|-------------|
| HR department standup | 2026-03-16 09:00 | 2026-03-16 09:30 |
| 1:1 with David O'Connell | 2026-03-16 10:00 | 2026-03-16 11:00 |
| Candidate pipeline review | 2026-03-16 11:00 | 2026-03-16 12:00 |
| Lunch break | 2026-03-16 12:00 | 2026-03-16 13:00 |
| Training program planning | 2026-03-16 13:00 | 2026-03-16 14:00 |
| Performance review prep | 2026-03-16 14:00 | 2026-03-16 15:30 |

**→ 最早工作时间空闲段：15:30–16:30**

---

### 检查项

| # | 检查域 | 检查方法 | 检查项 | 测试代码 |
|---|--------|---------|--------|---------|
| 1 | response | llm_judge | 回复正确识别出 Evelyn Hart 为两位候选人之一，并关联到 Engineering 部门 Database Engineer 岗位 | — |
| 2 | codebase | unittest | Evelyn Hart 的第二轮面评已正确提交，评分为 3.25，面试反馈内容不为空 | 见 `test_check_2` |
| 3 | codebase | extract_and_llm_judge | 提取 Evelyn Hart R2 面试记录的 feedback 字段，内容应忠实反映面评文档原文：**讨论**——(1) MySQL→PostgreSQL 大规模迁移方案（数据一致性验证、灰度切换、回滚预案）(2) Citus 分片下跨分片事务与 streaming replication RPO/RTO 权衡 (3) 索引优化、查询计划分析、vacuum 调参的性能调优 SOP (4) 模拟向非技术高管汇报的沟通场景。**优点**——(1) PostgreSQL 内核深入，从 WAL/存储引擎/vacuum 机制层面定位瓶颈 (2) Citus 分片实操扎实，清晰表达分片键与二级索引 trade-off (3) 迁移方案周全：checksum+shadow traffic 双写验证，灰度有流量百分比和监控指标，回滚有时间窗口约束。**不足**——(1) 云原生方案（CockroachDB/TiDB/Spanner）经验有限 (2) 高管汇报表达冗长，花 8 分钟讲 WAL 细节未先给结论 (3) NoSQL 混合持久化架构理解不足。评分 3.25 | 见 `test_check_3_extract` |
| 4 | response | llm_judge | 回复正确说明 Evelyn Hart 两轮面试得分 R1=3.50、R2=3.25，当前均分为 3.375，不满足快速通道条件，下一轮为 R3（HRBP 面试），面试官为 David O'Connell | — |
| 5 | response | llm_judge | 回复正确说明 David O'Connell 2026-03-16 最早的工作空闲时段为 11:00–12:00 | — |
| 6 | codebase | unittest | 已为 Evelyn Hart 安排第三轮面试，时间为 2026-03-16 11:00–12:00，未与 David O'Connell 当天已有日程冲突 | 见 `test_check_6` |
| 7 | codebase | unittest | 已通过 career@mollydigital.com 向 davidocon@mollydigital.com 发送面试通知邮件，标题为 "Interview Scheduled: 2026-03-16 11:00 - Evelyn Hart for Database Engineer (Engineering) Round 3" | 见 `test_check_7` |
| 8 | codebase | extract_and_llm_judge | 提取 #7 邮件的 body_content 字段，内容应包含：**(1) 面试时间与会议链接**——明确写出 2026-03-16 11:00-12:00 及 create_interview 返回的 meeting link。**(2) 简历摘要**——5 年数据库经验、PostgreSQL/MySQL 专长、DataVault 8TB 集群管理和 Citus 500M 行分片、CloudBase AWS RDS + GCP Cloud SQL 多云运维、Stanford CS 硕士。**(3) R1 反馈（Robert Fischer, 3.50）**——customer_id hash 分片思路实际、PostgreSQL 内核理解到位（vacuum/WAL）、迁移方法论扎实（shadow traffic 验证）；不足：级联故障防护偏理论化、对新一代分布式 SQL 不熟悉。**(4) R2 反馈（Sarah Chen, 3.25）**——WAL/存储引擎/vacuum 层面分析能力强、Citus 分片实操扎实、迁移方案含 checksum+shadow traffic 验证；不足：云原生经验有限、高管汇报花 8 分钟讲 WAL 细节未先给结论、NoSQL 混合架构理解不足。**(5) R3 HRBP 关注维度建议**——前两轮已充分考察技术深度，本轮应侧重文化价值观契合度、跨部门协作与沟通风格改善空间（呼应 R2 指出的"表达冗长"）、职业发展规划与稳定性、对云原生新技术的学习意愿、团队融入预期 | 见 `test_check_8_extract` |
| 9 | response | llm_judge | 回复正确识别出 Arjun Mehta 为两位候选人之一，关联到 Algorithm 部门 ML Researcher 岗位 | — |
| 10 | codebase | unittest | Arjun Mehta 的第二轮面评已正确提交，评分为 3.75，面试反馈内容不为空 | 见 `test_check_10` |
| 11 | codebase | extract_and_llm_judge | 提取 Arjun Mehta R2 面试记录的 feedback 字段，内容应忠实反映面评文档原文：**讨论**——(1) 推荐系统研究到生产完整链路：DeepRec transformer 模型从论文到 10M+ 用户，含模型压缩、在线服务架构、灰度上线 (2) DeepSpeed ZeRO-3 在 64 卡集群训练优化（72h→18h）(3) 支持 200+ 并发实验的 A/B 测试框架及 Bayesian early-stopping (4) LLM 在推荐系统中的前瞻应用 vs 产品交付平衡。**优点**——(1) 顶会论文产出顶尖（4 年 6 篇，NeurIPS spotlight/ICML/KDD）(2) 理论到实践转化强，推动 18% CTR 提升和 12% 收入增长 (3) LLM 增强推荐解释性和冷启动的前瞻性与平台方向契合。**不足**——(1) 工程化偏弱，SLA/降级/监控停留概念层面，缺少 p99<50ms 约束下实操 (2) 习惯两周一实验节奏，产品团队两天出 hotfix 需适应 (3) 追问"三天内简化方案"思考较长才给妥协方案。评分 3.75 | 见 `test_check_11_extract` |
| 12 | response | llm_judge | 回复正确说明 Arjun Mehta 两轮面试得分 R1=4.00、R2=3.75，当前均分为 3.875，均分 > 3.75 触发快速通道（Article 12），跳过 R3 HRBP 面试，下一轮为 R4（薪酬谈判），面试官为 Emily Watson（HR 主管） | — |
| 13 | response | llm_judge | 回复正确说明 Emily Watson 2026-03-16 最早的工作空闲时段为 15:30–16:30 | — |
| 14 | codebase | unittest | 已为 Arjun Mehta 安排第四轮面试（跳过第三轮），时间为 2026-03-16 15:30–16:30，未与 Emily Watson 当天已有日程冲突 | 见 `test_check_14` |
| 15 | codebase | unittest | 未向 Emily Watson 发送面试通知邮件，因为第四轮薪酬谈判不需要 summary email | 见 `test_check_15` |
| 16 | response | llm_judge | 回复对 Evelyn Hart 和 Arjun Mehta 的面试安排均给出完整执行摘要：面评提交结果（含评分）、下一轮安排（时间+面试官）、邮件发送情况、快速通道触发说明 | — |

### 测试代码

```python
"""
已知 ID（环境初始化时确定）:
  EVELYN_R2_INTERVIEW_ID  = 'interview-0204463c-4ad1-4503-9c93-468bd232509b'
  ARJUN_R2_INTERVIEW_ID   = 'interview-8b3f7a2e-6d19-4c5a-b8e1-9f2d4a7c3e6b'
  EVELYN_APPLICATION_ID   = 'application-107fae94-8808-4bed-ac13-86c7b15221df'
  ARJUN_APPLICATION_ID    = 'application-a3e5c891-7b24-4f68-9d12-6e8b3f5a2c47'
"""

# ── #2 Evelyn Hart R2 面试记录提交 ──
def test_check_2(db):
    row = db.fetch_one(
        "SELECT interview_status, score, feedback "
        "FROM interview WHERE interview_id = %s",
        [EVELYN_R2_INTERVIEW_ID]
    )
    assert row is not None, "Evelyn Hart R2 面试记录不存在"
    assert row["interview_status"] == "Completed", \
        f"状态应为 Completed，实际为 {row['interview_status']}"
    assert float(row["score"]) == 3.25, \
        f"评分应为 3.25，实际为 {row['score']}"
    assert row["feedback"] is not None and len(row["feedback"].strip()) > 0, \
        "feedback 字段为空"


# ── #3 提取 Evelyn Hart R2 feedback 供 LLM judge ──
def test_check_3_extract(db):
    row = db.fetch_one(
        "SELECT feedback FROM interview WHERE interview_id = %s",
        [EVELYN_R2_INTERVIEW_ID]
    )
    assert row is not None and row["feedback"]
    return row["feedback"]  # 交给 llm_judge 评估


# ── #6 Evelyn Hart R3 面试记录与日程创建 ──
def test_check_6(db):
    row = db.fetch_one(
        "SELECT interview_id, interview_status, schedule_id "
        "FROM interview "
        "WHERE job_application_id = %s AND interview_status = 'Scheduled'",
        [EVELYN_APPLICATION_ID]
    )
    assert row is not None, "未找到 Evelyn Hart 新增的 Scheduled 面试记录"
    assert row["interview_status"] == "Scheduled"

    schedule = db.fetch_one(
        "SELECT start_datetime, end_datetime "
        "FROM schedule WHERE schedule_id = %s",
        [row["schedule_id"]]
    )
    assert schedule is not None, "关联的日程事件不存在"
    assert str(schedule["start_datetime"]) == "2026-03-16 11:00:00", \
        f"开始时间应为 11:00，实际为 {schedule['start_datetime']}"
    assert str(schedule["end_datetime"]) == "2026-03-16 12:00:00", \
        f"结束时间应为 12:00，实际为 {schedule['end_datetime']}"


# ── #7 面试官通知邮件发送 ──
def test_check_7(db):
    row = db.fetch_one(
        "SELECT email_id, subject FROM email "
        "WHERE sender_email = 'career@mollydigital.com' "
        "  AND receiver_email = 'davidocon@mollydigital.com' "
        "ORDER BY created_at DESC LIMIT 1"
    )
    assert row is not None, "未找到 career@ 发送给 davidocon@ 的邮件"
    expected_subject = (
        "Interview Scheduled: 2026-03-16 11:00 - "
        "Evelyn Hart for Database Engineer (Engineering) Round 3"
    )
    assert expected_subject in row["subject"] or row["subject"] == expected_subject, \
        f"邮件标题不匹配，实际为: {row['subject']}"


# ── #8 提取通知邮件 body 供 LLM judge ──
def test_check_8_extract(db):
    row = db.fetch_one(
        "SELECT body_content FROM email "
        "WHERE sender_email = 'career@mollydigital.com' "
        "  AND receiver_email = 'davidocon@mollydigital.com' "
        "ORDER BY created_at DESC LIMIT 1"
    )
    assert row is not None and row["body_content"]
    return row["body_content"]  # 交给 llm_judge 评估


# ── #10 Arjun Mehta R2 面试记录提交 ──
def test_check_10(db):
    row = db.fetch_one(
        "SELECT interview_status, score, feedback "
        "FROM interview WHERE interview_id = %s",
        [ARJUN_R2_INTERVIEW_ID]
    )
    assert row is not None, "Arjun Mehta R2 面试记录不存在"
    assert row["interview_status"] == "Completed", \
        f"状态应为 Completed，实际为 {row['interview_status']}"
    assert float(row["score"]) == 3.75, \
        f"评分应为 3.75，实际为 {row['score']}"
    assert row["feedback"] is not None and len(row["feedback"].strip()) > 0, \
        "feedback 字段为空"


# ── #11 提取 Arjun Mehta R2 feedback 供 LLM judge ──
def test_check_11_extract(db):
    row = db.fetch_one(
        "SELECT feedback FROM interview WHERE interview_id = %s",
        [ARJUN_R2_INTERVIEW_ID]
    )
    assert row is not None and row["feedback"]
    return row["feedback"]  # 交给 llm_judge 评估


# ── #14 Arjun Mehta R4 面试记录与日程创建 ──
def test_check_14(db):
    row = db.fetch_one(
        "SELECT interview_id, interview_status, schedule_id "
        "FROM interview "
        "WHERE job_application_id = %s AND interview_status = 'Scheduled'",
        [ARJUN_APPLICATION_ID]
    )
    assert row is not None, "未找到 Arjun Mehta 新增的 Scheduled 面试记录"
    assert row["interview_status"] == "Scheduled"

    schedule = db.fetch_one(
        "SELECT start_datetime, end_datetime "
        "FROM schedule WHERE schedule_id = %s",
        [row["schedule_id"]]
    )
    assert schedule is not None, "关联的日程事件不存在"
    assert str(schedule["start_datetime"]) == "2026-03-16 15:30:00", \
        f"开始时间应为 15:30，实际为 {schedule['start_datetime']}"
    assert str(schedule["end_datetime"]) == "2026-03-16 16:30:00", \
        f"结束时间应为 16:30，实际为 {schedule['end_datetime']}"


# ── #15 不应存在发给 Emily Watson 的面试安排邮件 ──
def test_check_15(db):
    row = db.fetch_one(
        "SELECT COUNT(*) AS cnt FROM email "
        "WHERE sender_email = 'career@mollydigital.com' "
        "  AND subject LIKE '%%Interview Scheduled%%Arjun Mehta%%'"
    )
    assert row["cnt"] == 0, \
        f"不应为 R4 薪酬谈判发送通知邮件，但找到了 {row['cnt']} 封"
```

---

## 4. Summarization

| # | 难点 | 说明 | 标注备注 |
|---|------|------|---------|
| 1 | 隐式信息定位 | 用户说"昨天的两位候选人"，没给名字。agent 必须走一步才能知道是谁——要么查 Sarah 的 3/14 日程，要么搜"Sarah面评文档"然后读。很多 model 会直接问"请问是哪两位候选人"，那就扣分了 | 这是个 grounding 门槛，过不了这关后面全白搭。观察下来大部分失败 case 死在这里 |
| 2 | 一个 prompt 两条完全不同的分支 | 两个候选人看着是同一个任务，但 Evelyn 走常规 R3、Arjun 触发快速通道直接跳 R4，面试官、邮件规则都不一样。这是这个 case 最核心的设计——同一批处理里藏了条件分支 | 不少 model 图省事两个人都按 R3 安排了，或者两个都触发了快速通道。关键是 3.375 vs 3.875 一个在线下一个在线上，差距不大但结论完全相反 |
| 3 | 快速通道的精确条件 | Article 12 写的是"exceeds 3.75"，严格大于。均分 3.875 > 3.75 ✓。如果有个 case 刚好 3.75 就不应该触发，这里 3.875 没有歧义，但 agent 必须知道去查 policy 里的这条规则并且算对均分 | (3.50+3.25)/2=3.375 和 (4.00+3.75)/2=3.875，计算本身不难，难的是知道要算、知道拿什么跟什么比 |
| 4 | 组织架构多级推理 | R3 面试官 = "部门 HRBP" → 查 Engineering 部门 → HRBP 是 David O'Connell。R4 面试官 = "HR 部门主管" → Emily Watson。agent 需要理解"HRBP"和"HR主管"不是一个人，而且要从 org 里正确定位 | 有些 model 分不清 HRBP 和 HR Manager，直接把 Emily Watson 当 HRBP 或者把 David O'Connell 当 HR 主管 |
| 5 | 日程冲突避免 | 用户说"明天最早的空闲时间"，agent 要查面试官 3/16 全天日程、排除已有安排、找第一个空档。David O'Connell 上午排满到 11:00 所以最早是 11:00–12:00；Emily Watson 排满到 15:30 所以最早是 15:30–16:30 | 有的 model 会直接安排 9:00 或 10:00，没看日程就开排。也有的安排在 12:00–13:00 午休时段 |
| 6 | R4 不发邮件 | policy 明确写了第四轮谈薪不需要发 summary email。这是个反直觉的点——前面 Evelyn 发了邮件，到 Arjun 这里惯性思维很容易也发一封 | 这条是 negative check，不做某事有时候比做某事更难判断。agent 容易"多做"而不是"少做" |
| 7 | 面评文档→feedback 提交的信息保真 | Sarah 的面评文档里写了很具体的讨论细节（"花了 8 分钟讲 WAL 细节""追问三天内如何简化方案时思考了较长时间"），agent 提交的 feedback 需要保留这些具体信息，不能泛化成"沟通能力有待提高" | rubric_check 会逐条对比面评文档原文和提交的 feedback。越具体的信息越容易在 agent 转述时丢失 |
| 8 | 邮件内容的综合分析能力 | 给 David O'Connell 的通知邮件不是简单转发——要综合简历（5 年经验、Stanford 硕士、Citus 分片）+ R1 反馈（分片方案实际、级联故障理论化）+ R2 反馈（迁移方案周全、表达冗长）+ R3 HRBP 视角的关注维度建议。这是个"阅读理解+分析+生成"的综合任务 | 最容易出问题的是"R3 关注维度建议"——好的回答应该跟前两轮技术面形成互补（前两轮考察技术深度，HRBP 应侧重文化契合、沟通改善空间等软性维度），而不是再出一堆技术问题 |
| 9 | 发件人必须是 career@ | policy 限定了招聘场景用 career@mollydigital.com 发件，不能用 Sarah 个人邮箱也不能用 hr@。这是个容易忽略的细节 | 有 model 用当前用户的邮箱发，有的用 hr@ 发，都算错 |
