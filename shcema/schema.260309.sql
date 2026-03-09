CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    manager_employee_id INT, -- 部门主管
    hrbp_employee_id INT, -- 关联的HRBP
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(50),
    gender ENUM('Male', 'Female', 'Other'),
    department_id INT,
    supervisor_employee_id INT, -- 直属上级 (+1)
    base_salary DECIMAL(12, 2), -- 税前月薪
    onboard_at DATE NOT NULL,
    quit_at DATE,
    permissions JSON, -- 存储细粒度权限
    employee_status ENUM('Active', 'Resigned') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE job_openings (
    job_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    department_id INT,
    base_location VARCHAR(100),
    responsibilities TEXT,
    requirements TEXT,
    bonus_points TEXT,
    salary_min DECIMAL(12, 2),
    salary_max DECIMAL(12, 2),
    job_opening_status ENUM('Open', 'Closed') DEFAULT 'Open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE candidates (
    candidate_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    resume_content TEXT,
    lock_until DATE, -- 用于处理“冷静期”锁定
    last_rejection_reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE job_applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    candidate_id INT NOT NULL,
    -- 严格对应政策中的流转状态
    job_application_stage ENUM(
        'Pending_Assessment', -- 简历入库待评估
        'Interview_Scheduled', -- 约面
        'Round_1_Completed',    -- 完成一面
        'Round_2_Completed',    -- 完成二面
        'Round_3_Completed',    -- 完成三面
        'Round_4_Completed',    -- 完成四面（可跳过）
        'Salary_Negotiation',  -- 谈薪
        'Pending_Onboarding',  -- 待入职
        'Onboarded',           -- 入职
        'Rejected',            -- 流程终止（未通过）
        'Withdrawn'            -- 候选人主动放弃（包含薪资问题或毁约）
    ) DEFAULT 'Pending_Assessment',
    interview_id_list INT[] DEFAULT [],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE interviews (
    interview_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    -- 面试维度
    round_number INT NOT NULL CHECK (round_number IN (1, 2, 3, 4)), -- 1: Peer, 2: Manager, 3: CTO/CEO, 4: HRBP
    interviewer_id INT NOT NULL, -- 指派的面试官 (Peer/主管/CTO/HRBP)
    -- 状态流转
    -- Interview_Scheduled: 已排期待面试 | Completed: 已评分结束 | Cancelled: 取消 | Skipped: 跳过本轮
    interview_status ENUM('Interview_Scheduled', 'Completed', 'Cancelled', 'Skipped') DEFAULT 'Interview_Scheduled',
    -- 时间管理
    scheduled_at DATETIME NOT NULL, -- 约定的起始时间
    start_at DATETIME, -- 实际开始时间
    end_at DATETIME, -- 面试结束时间（用于触发2个工作日评分提醒）
    -- 评分结果
    score DECIMAL(3, 2) CHECK (score IN (3.0, 3.25, 3.5, 3.75, 4.0)), -- 强制约束分值
    feedback TEXT, -- 面试评价
    scored_at DATETIME, -- 实际提交评分的时间
    --
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE employee_okr_records (
    employee_id INT NOT NULL,
    year YEAR NOT NULL,
    quarter ENUM('Q1', 'Q2', 'Q3', 'Q4') NOT NULL,
    okr_status ENUM('Goal_Setting', 'In_Progress', 'Reviewing', 'Completed') DEFAULT 'Goal_Setting',
    -- OKR 核心内容
    okr_objectives TEXT, -- 存储季度目标列表
    okr_review_summary TEXT, -- 季度末员工提交的复盘内容
    -- 评级逻辑
    rating ENUM('S', 'A', 'B', 'C') DEFAULT NULL,
    evaluator_employee_id INT, -- 部门主管/CTO/CEO 的员工ID
    rated_at DATETIME,
    --
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (employee_id, year, quarter),
);

CREATE TABLE employee_salary_records (
    employee_id INT NOT NULL,
    year YEAR NOT NULL,
    month INT NOT NULL CHECK (month in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)),
    base_salary DECIMAL(12, 2) NOT NULL, -- 发放时的基本月薪快照
    -- 薪资构成
    overtime_pay DECIMAL(12, 2) DEFAULT 0.00, -- 三倍日薪加班费
    deduction_amount DECIMAL(12, 2) DEFAULT 0.00, -- 无薪事假/病假扣款
    year_end_bonus DECIMAL(12, 2) DEFAULT 0.00, -- 仅在1月发放时有值
    -- 核心公式参数快照
    final_payout DECIMAL(12, 2) NOT NULL, -- 最终税前实发
    payout_status ENUM('Pending', 'Paid') DEFAULT 'Pending',
    paid_at DATETIME,
    --
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (employee_id, year, month),
);

CREATE TABLE erp_resource_requests (
    resource_request_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    -- 流程整体状态（对应政策中的流转）
    approval_request_stage ENUM(
        'Supervisor_Approval',  -- 主管审批中
        'Finance_Approval',     -- 财务审批中
        'Completed',            -- 全部通过
        'Rejected',             -- 已驳回
        'Canceled'              -- 已撤销
    ) DEFAULT 'Supervisor_Approval',
    --
    category ENUM('Laptop', 'Monitor', 'Mobile', 'Token') NOT NULL,
    amount INT NOT NULL,
    detail_description TEXT, -- 申请详情
    --
    approval_round_id_list INT[] DEFAULT [],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE erp_leave_requests (
    leave_request_id INT PRIMARY KEY AUTO_INCREMENT,
    -- 流程整体状态（对应政策中的流转）
    approval_request_stage ENUM(
        'Supervisor_Approval',  -- 主管审批中
        'Finance_Approval',     -- 财务审批中
        'Completed',            -- 全部通过
        'Rejected',             -- 已驳回
        'Canceled'              -- 已撤销
    ) DEFAULT 'Supervisor_Approval',
    -- 请假业务字段
    leave_type ENUM(
        'Statutory_Annual',           -- 法定年假
        'Tenure_Annual',           -- 司龄年假
        'Paid_Sick',        -- 5天带薪病假
        'Unpaid_Sick',             -- 不限期病假（无薪）
        'Unpaid_Personal',         -- 不限期事假（无薪）
        'Funeral',          -- 丧假
        'Marital',          -- 婚假
        'Paternity'         -- 陪产假
    ) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INT NOT NULL CHECK (total_days >= 1), -- 政策：最小单位为1个工作日
    detail_description TEXT, -- 申请详情
    material_url_list VARCHAR(255)[] DEFAULT [], -- 证明材料
    --
    approval_round_id_list INT[] DEFAULT [],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE erp_approval_rounds (
    approval_round_id INT PRIMARY KEY AUTO_INCREMENT,
    approval_request_id INT NOT NULL,
    applicant_employee_id INT NOT NULL,
    approver_employee_id INT NOT NULL,
    round_status ENUM('Pending', 'Approved', 'Rejected', 'Canceled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE erp_leave_balances (
    employee_id INT PRIMARY KEY,
    statutory_annual_days INT DEFAULT 5,
    tenure_annual_days INT DEFAULT 1,
    paid_sick_days INT DEFAULT 5,
    year YEAR,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (employee_id, year),
);