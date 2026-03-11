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
    phone VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(50),
    gender ENUM('Male', 'Female', 'Other'),
    department_id INT,
    responsibility TEXT,
    supervisor_employee_id INT, -- 直属上级
    monthly_salary DECIMAL(12, 2), -- 税前月薪
    permissions JSON, -- 存储细粒度权限
    employee_status ENUM('Active', 'Resigned') DEFAULT 'Active',
    onboard_at DATE NOT NULL,
    quit_at DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE job_description (
    job_description_id INT PRIMARY KEY AUTO_INCREMENT,
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE job_application (
    job_application_id INT PRIMARY KEY AUTO_INCREMENT,
    job_description_id INT NOT NULL,
    candidate_id INT NOT NULL,
    -- 严格对应政策中的流转状态
    job_application_stage ENUM(
        'Assessing', -- 评估中
        'Interviewing', -- 面试中
        'Negotiating',  -- 谈薪中
        'Accepted',  -- 已接受offer
        'Rejected',    -- 未通过
        'Onboarded', -- 已入职
        'Withdrawn', -- 候选人主动放弃
    ) DEFAULT 'Assessing',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE schedule (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    
    content TEXT,
    
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE interview (
    interview_id INT PRIMARY KEY AUTO_INCREMENT,
    job_application_id INT NOT NULL,

    -- 面试维度
    interviewer_employee_id INT NOT NULL, -- 指派的面试官 ID
    interview_status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    schedule_id INT NOT NULL,

    score DECIMAL(3, 2) CHECK (score IN (3.0, 3.25, 3.5, 3.75, 4.0)), -- 强制约束分值
    feedback TEXT, -- 面试评价

    scored_at DATETIME, -- 实际提交评分的时间
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE okr (
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

CREATE TABLE salary (
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

CREATE TABLE resource_request (
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE leave_request (
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
    --
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
    membership_tier ENUM('None', 'Platinum', 'Black Gold') DEFAULT 'None',
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

CREATE TABLE camera_sku (
    camera_sku_id INT PRIMARY KEY AUTO_INCREMENT,
    
    brand ENUM(
        'Agfa', 'Canon', 'Casio', 'Contax', 'DJI', 'DxO Labs', 'Epson', 
        'Fujifilm', 'GoPro', 'Hasselblad', 'Holga', 'HP', 'Kodak', 
        'Konica Minolta', 'Kyocera', 'Leica', 'Lytro', 'Nikon', 
        'OM System / Olympus', 'Panasonic', 'Pentax', 'Pixii', 
        'Ricoh', 'Samsung', 'Sanyo', 'SeaLife', 'Sigma', 'Sony', 
        'Toshiba', 'YI', 'Zeiss'
    ) NOT NULL,
    
    model_name TEXT,

    body_type TEXT,
    max_resolution TEXT,
    effective_pixels TEXT,
    sensor_size TEXT,
    sensor_type TEXT,
    iso TEXT,
    lens_mount TEXT,
    focal_length_mult TEXT,
    articulated_lcd TEXT,
    screen_size TEXT,
    screen_dots TEXT,
    max_shutter_speed TEXT,
    format TEXT,
    storage_types TEXT,
    usb TEXT,
    weight_inc_batteries TEXT,
    dimensions TEXT,
    gps TEXT,

    announced_at DATETIME,
    description TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE lens_sku (
    lens_sku_id INT PRIMARY KEY AUTO_INCREMENT,
    
    brand ENUM(
        'Agfa', 'Canon', 'Casio', 'Contax', 'DJI', 'DxO Labs', 'Epson', 
        'Fujifilm', 'GoPro', 'Hasselblad', 'Holga', 'HP', 'Kodak', 
        'Konica Minolta', 'Kyocera', 'Leica', 'Lytro', 'Nikon', 
        'OM System / Olympus', 'Panasonic', 'Pentax', 'Pixii', 
        'Ricoh', 'Samsung', 'Sanyo', 'SeaLife', 'Sigma', 'Sony', 
        'Toshiba', 'YI', 'Zeiss', 'Tamron', 'Viltrox'
    ) NOT NULL,
    
    model_name TEXT,

    lens_type TEXT,
    focal_length TEXT,
    image_stab TEXT,   
    lens_mount TEXT,
    max_aperture TEXT,
    min_aperture TEXT,
    min_focus TEXT,
    weight TEXT,
    length TEXT,

    announced_at DATETIME,
    description TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    sku_type ENUM(
        'Camera',         -- 相机
        'Lens',           -- 镜头
    ) NOT NULL, 
    sku_id INT NOT NULL, 
    product_name VARCHAR(255) NOT NULL, -- 冗余名称方便展示
    stock_quantity INT NOT NULL DEFAULT 1,

    manufacturer_suggested_retail_price DECIMAL(12, 2) NOT NULL, -- 制造商建议零售价
    price DECIMAL(12, 2) NOT NULL, -- 当前销售价格
    is_special_offer BOOLEAN DEFAULT FALSE, -- 是否为特价产品（政策：特价不享受会员折扣）
    is_returnable BOOLEAN DEFAULT TRUE, -- 对应政策：明确标注不在退货范围内的商品

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE order (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,

    -- 对应政策中的 8 种状态
    order_status ENUM(
        'Submitted', 
        'Paid', 
        'Shipped', 
        'Delivered', 
        'Completed', 
        'Requesting_Refund', 
        'Refunded', 
        'Canceled'
    ) DEFAULT 'Submitted',
    
    -- 购物金额计算
    product_amount DECIMAL(12, 2) NOT NULL, -- 产品
    shipping_fee DECIMAL(12, 2) DEFAULT 0.00,    -- 运费（金级会员免运费）
    handling_fee_when_purchased DECIMAL(12, 2) DEFAULT 0.00,    -- 银行转账手续费
    total_amount DECIMAL(12, 2) NOT NULL, -- 最终应付：产品 + 运费 + 手续费
    -- 退款金额计算
    product_amount_refunded DECIMAL(12, 2) NOT NULL,
    shipping_fee_refunded DECIMAL(12, 2) DEFAULT 0.00, -- 质量问题补10刀，无理由为0
    total_refund_amount DECIMAL(12, 2) NOT NULL, -- 最终退款：产品 + 运费
    
    -- 时间线
    paid_at DATETIME,
    shipped_at DATETIME,
    delivered_at DATETIME,
    completed_at DATETIME,
    requesting_refund_at DATETIME,
    refunded_at DATETIME,
    canceled_at DATETIME,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE order_item (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    -- 下单时的快照
    unit_price_snapshot DECIMAL(12, 2) NOT NULL, -- 下单时的单价快照
    is_special_offer_snapshot BOOLEAN, -- 记录下单时是否为特价
    is_refundable_snapshot BOOLEAN, -- 记录下单时是否为可退货
    quantity INT NOT NULL,
    total_item_amount DECIMAL(12, 2) NOT NULL, -- 单品订单金额
    -- 退货 
    is_refunded BOOLEAN DEFAULT FALSE,
    refunded_quantity INT DEFAULT 0,
    --
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,

    payment_method ENUM(
        'Online', 
        'Bank_Transfer'
    ) NOT NULL,

    payment_status ENUM(
        'Waiting_For_Confirmation', 
        'Confirmed', 
        'Fail_To_Confirm',
        'Canceled'
    ) DEFAULT 'Waiting_For_Confirmation',
    
    -- 转账逻辑
    transaction_id VARCHAR(100), -- 第三方支付单号
    send_amount DECIMAL(12, 2) NOT NULL,
    sender_name VARCHAR(100),
    sender_account_number VARCHAR(100),
    receive_amount DECIMAL(12, 2) NOT NULL,
    receiver_name VARCHAR(100) DEFAULT 'Molly Digital Inc.',
    receiver_account_number VARCHAR(100) DEFAULT '99000000000000000000000000000000',
    handling_fee DECIMAL(12, 2) DEFAULT 0.00,

    -- 确认收款
    confirm_deadline DATETIME, -- +3个自然日
    confirmed_by_employee_id INT, -- 政策：11:00 确认收款的工作人员 ID

    -- 时间线
    waiting_for_confirmation_at DATETIME,
    confirmed_at DATETIME,
    failed_at DATETIME,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE shipping (
    shipping_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,

    shipping_method ENUM(
        'FedEx_Standard',
        'FedEx_Next_Day'
    ) NOT NULL,

    shipping_status ENUM(
        'Ordered',
        'Shipped',
        'Delivered',
        'Canceled'
    ) DEFAULT 'Ordered',

    tracking_number VARCHAR(100), -- 第三方物流单号
    sender_name VARCHAR(100),
    sender_phone VARCHAR(50),
    sender_address TEXT,
    receiver_name VARCHAR(100),
    receiver_phone VARCHAR(50),
    receiver_address TEXT,

    -- 时间线
    ordered_at DATETIME,
    shipped_at DATETIME,
    delivered_at DATETIME,
    canceled_at DATETIME,

    -- 
    shipping_fee DECIMAL(12, 2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE refund (
    refund_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,

    refund_type ENUM(
        'No_Reason', 
        'Quality_Issue'
    ) NOT NULL,

    refund_status ENUM(
        'Requesting_Refund', 
        'Item_Received_and_Inspected',
        'Passed_Inspection',
        'Refunded',
        'Failed_Inspection'
    ) DEFAULT 'Requesting_Refund',
    
    -- 仓库检查记录：是否影响二次销售，用于退款金额计算
    inspection_notes TEXT,

    -- 转账逻辑
    transaction_id VARCHAR(100), -- 第三方支付单号
    send_amount DECIMAL(12, 2) NOT NULL,
    sender_name VARCHAR(100) DEFAULT 'Molly Digital Inc.',
    sender_account_number VARCHAR(100) DEFAULT '99000000000000000000000000000000',
    receive_amount DECIMAL(12, 2) NOT NULL,
    receiver_name VARCHAR(100) DEFAULT,
    receiver_account_number VARCHAR(100),
    handling_fee DECIMAL(12, 2) DEFAULT 0.00,
    
    -- 确认退款
    refunded_deadline DATETIME,
    refunded_by_employee_id INT,

    -- 时间线
    requesting_refund_at DATETIME,
    item_received_and_inspected_at DATETIME,
    passed_inspection_at DATETIME,
    refunded_at DATETIME,
    failed_inspection_at DATETIME,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE ticket (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_id INT, -- 可选，关联特定订单
    assignee_employee_id INT, -- 处理工单的员工（客服/仓库人员）
    
    -- 工单分类：产品咨询、订单问题、技术支持、投诉
    ticket_type ENUM(
        'Product_Inquiry', 
        'Order', 
        'Technical_Support',
        'Complaint', 
    ) DEFAULT 'Product_Inquiry',

    -- 工单状态
    ticket_status ENUM(
        'Open',         -- 开启（等待处理）
        'Resolved',     -- 已解决
        'Closed'        -- 已关闭
    ) DEFAULT 'Open',

    -- 优先级：根据会员等级或问题严重程度分配
    priority ENUM(
        'Low', 
        'Medium', 
        'High', 
        'Urgent'
    ) DEFAULT 'Medium',

    title VARCHAR(255) NOT NULL, -- 工单标题/简述
    content TEXT NOT NULL,       -- 客户描述的问题详情
    response TEXT NOT NULL,      -- 客服回复

    -- 时间线
    open_at DATETIME,
    resolved_at DATETIME,
    closed_at DATETIME,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE email (
    email_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_email VARCHAR(100) NOT NULL,
    receiver_email VARCHAR(100) NOT NULL,
    cc_emails TEXT, -- 对应政策：招聘时邮件需抄送用人部门主管
    
    subject VARCHAR(255) NOT NULL,
    body_content TEXT NOT NULL,

    sent_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE document (
    document_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    
    -- 内容存储：支持 Markdown 或 HTML 格式
    content_body LONGTEXT NOT NULL,
    
    -- 知识库分类
    -- Internal: 内部文档（仅员工可见）
    -- External: 外部文档（客户、会员、访客可见）
    document_type ENUM(
        'Internal', 
        'External'
    ) NOT NULL DEFAULT 'External',
    
    -- 文档状态：草稿、已发布、已归档（废弃）
    document_status ENUM(
        'Published', 
        'Archived'
    ) DEFAULT 'Draft',
    
    -- 权限与责任制
    author_employee_id INT NOT NULL, -- 撰写人

    -- SEO 与 检索
    slug VARCHAR(100) UNIQUE, -- 用于 URL 展示，如 /kb/return-policy
    tags JSON,                -- 存储标签，如 ["相机", "二手", "S级"]
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
);