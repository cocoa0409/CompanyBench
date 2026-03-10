CREATE TABLE department (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    manager_employee_id INT, -- 部门主管
    hrbp_employee_id INT, -- 关联的HRBP
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE employee (
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

CREATE TABLE job_opening (
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

CREATE TABLE candidate (
    candidate_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    resume_content TEXT,
    lock_until DATE, -- 用于处理“冷静期”锁定
    last_rejection_reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE job_application (
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

CREATE TABLE interview (
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

CREATE TABLE employee_okr_record (
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

CREATE TABLE employee_salary_record (
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

CREATE TABLE erp_resource_approval_request (
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

CREATE TABLE erp_leave_request (
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
        'Overtime',             -- 加班
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

CREATE TABLE erp_approval_round (
    approval_round_id INT PRIMARY KEY AUTO_INCREMENT,
    approval_request_id INT NOT NULL,
    applicant_employee_id INT NOT NULL,
    approver_employee_id INT NOT NULL,
    round_status ENUM('Pending', 'Approved', 'Rejected', 'Canceled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE erp_leave_balance (
    employee_id INT PRIMARY KEY,
    statutory_annual_days INT DEFAULT 5,
    tenure_annual_days INT DEFAULT 1,
    paid_sick_days INT DEFAULT 5,
    year YEAR,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (employee_id, year),
);

-- ============================================================
-- 商业模式
-- ============================================================

CREATE TABLE customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(50) NOT NULL,
    identification_number VARCHAR(100) UNIQUE NOT NULL,
    addresses TEXT[] DEFAULT [],
    -- Bronze: >500刀享5%折扣 | Silver: >2000刀享10%折扣 | Gold: >4000刀享20%折扣+免运费
    membership_tier ENUM('None', 'Bronze', 'Silver', 'Gold') DEFAULT 'None',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE manufacturer (
    manufacturer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(100),
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE camera (
    camera_id INT PRIMARY KEY AUTO_INCREMENT,
    brand ENUM(
        'Sony',         -- 索尼：Alpha 系列、Cinema Line
        'Canon',        -- 佳能：EOS R/EOS EF 系列
        'Nikon',        -- 尼康：Z 系列、D 系列
        'Fujifilm',     -- 富士：X 系列、GFX 系列
        'Panasonic',    -- 松下：LUMIX S/G 系列
        'Leica',        -- 徕卡：M/SL/Q 系列
        'Hasselblad',   -- 哈苏：中画幅系统
    ) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    sensor_size ENUM(
        'Full Frame',        -- 全画幅 (35mm)
        'APS-C',             -- 半画幅
        'Medium Format',     -- 中画幅
        'Micro Four Thirds', -- M43 系统
        '1-inch',            -- 1英寸（黑卡/卡片机）
    ) NOT NULL,
    body_type ENUM(
        'Mirrorless',   -- 无反/微单：主流趋势
        'DSLR',         -- 单反：传统光学取景
        'Compact',      -- 固定镜头相机/卡片机
        'Rangefinder',  -- 旁轴相机：如徕卡M
        'Cinema'        -- 专业电影机：如 FX6, C70
    ) NOT NULL,
    mount_type ENUM(
        'E-Mount',      -- 索尼 E
        'RF-Mount',     -- 佳能 RF
        'Z-Mount',      -- 尼康 Z
        'X-Mount',      -- 富士 X
        'L-Mount',      -- 马徕松 L 联盟
        'M-Mount',      -- 徕卡 M
        'GF-Mount',     -- 富士 GFX
        'EF-Mount',     -- 佳能单反 EF
        'F-Mount',      -- 尼康单反 F
        'PL-Mount'      -- 电影工业常用 PL
    ) NOT NULL,
    max_resolution INT, -- 单位为百万像素(MP)，如 61 代表 6100万像素，方便排序
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE lens (
    lens_id INT PRIMARY KEY AUTO_INCREMENT,
    brand ENUM(
        'Sony',         -- 索尼
        'Canon',        -- 佳能
        'Nikon',        -- 尼康
        'Fujifilm',     -- 富士
        'Sigma',        -- 适马：Art/Contemporary 系列
        'Tamron',       -- 腾龙
        'Zeiss',        -- 蔡司
        'Viltrox',      -- 唯卓仕
        'Other'
    ) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    lens_type ENUM(
        'Prime',        -- 定焦镜头
        'Zoom',         -- 变焦镜头
        'Macro',        -- 微距镜头
        'Fisheye',      -- 鱼眼镜头
        'Tilt-Shift',   -- 移轴镜头
        'Anamorphic'    -- 电影变形宽银幕镜头
    ) NOT NULL,
    mount_type ENUM(
        'E-Mount',      -- 索尼 E
        'RF-Mount',     -- 佳能 RF
        'Z-Mount',      -- 尼康 Z
        'X-Mount',      -- 富士 X
        'L-Mount',      -- 马徕松 L 联盟
        'M-Mount',      -- 徕卡 M
        'GF-Mount',     -- 富士 GFX
        'EF-Mount',     -- 佳能单反 EF
        'F-Mount',      -- 尼康单反 F
        'PL-Mount'      -- 电影工业常用 PL
    ) NOT NULL,
    focal_length_min_mm DECIMAL(5,1),  -- 最小焦距（单位mm），如 24.0
    focal_length_max_mm DECIMAL(5,1),  -- 最大焦距（单位mm），如 70.0；定焦镜头两者相等
    aperture_min_f DECIMAL(4,2),       -- 最小光圈（最大通光量），如 1.20
    aperture_max_f DECIMAL(4,2),       -- 最大光圈（最小通光量），如 22.00
    filter_size_mm INT,       -- 滤镜口径，方便客户配滤镜
    has_stabilization BOOLEAN DEFAULT FALSE, -- 是否内置光学防抖 (OSS/IS/VR)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
