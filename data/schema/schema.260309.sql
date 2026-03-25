-- ============================================================
-- 企业管理
-- ============================================================

CREATE TABLE department (
    department_id INT PRIMARY KEY AUTO_INCREMENT, -- 部门唯一标识
    name VARCHAR(100) NOT NULL, -- 部门名称
    manager_employee_id INT, -- 部门主管的员工ID
    hrbp_employee_id INT, -- 该部门对接的HRBP的员工ID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT, -- 员工唯一标识
    name VARCHAR(100) NOT NULL, -- 员工姓名
    email VARCHAR(100) UNIQUE NOT NULL, -- 员工邮箱（唯一）
    phone VARCHAR(50) UNIQUE NOT NULL, -- 员工电话（唯一）
    title VARCHAR(50), -- 职位名称
    gender ENUM(
        'Male',   -- 男性
        'Female', -- 女性
        'Other'   -- 其他
    ), -- 性别
    department_id INT, -- 所属部门ID
    supervisor_employee_id INT, -- 直属上级的员工ID

    responsibility TEXT, -- 岗位职责描述
    monthly_salary DECIMAL(12, 2), -- 税前月薪 (严格保密)
    permissions JSON, -- 系统权限 (严格保密)

    employee_status ENUM(
        'Active',   -- 在职
        'Resigned'  -- 已离职
    ) DEFAULT 'Active', -- 员工在职状态
    onboard_at DATE NOT NULL, -- 入职日期
    quit_at DATE, -- 离职日期
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);

CREATE TABLE jd (
    jd_id INT PRIMARY KEY AUTO_INCREMENT, -- 岗位JD唯一标识
    title VARCHAR(100), -- 岗位名称
    department_id INT, -- 所属部门ID
    base_location VARCHAR(100), -- 工作地点
    responsibilities TEXT, -- 工作职责
    requirements TEXT, -- 任职要求
    bonus_points TEXT, -- 加分项
    salary_min DECIMAL(12, 2), -- 薪资范围下限（月薪×16）
    salary_max DECIMAL(12, 2), -- 薪资范围上限（月薪×16）
    jd_status ENUM(
        'Open',   -- 开放招聘中
        'Closed'  -- 已关闭
    ) DEFAULT 'Open', -- 岗位招聘状态
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE candidate (
    candidate_id INT PRIMARY KEY AUTO_INCREMENT, -- 候选人唯一标识
    name VARCHAR(100), -- 候选人姓名
    email VARCHAR(100) UNIQUE, -- 候选人邮箱
    resume_content TEXT, -- 简历内容
    candidate_status ENUM(
        'Active',   -- 活跃
        'Hired',    -- 已录用
        'Rejected'  -- 已拒绝
    ) DEFAULT 'Active', -- 候选人状态
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE job_application (
    job_application_id INT PRIMARY KEY AUTO_INCREMENT, -- 求职申请唯一标识
    jd_id INT NOT NULL, -- 关联的岗位JD ID
    candidate_id INT NOT NULL, -- 关联的候选人ID
    job_application_status ENUM(
        'Assessing',    -- 简历评估中
        'Interviewing', -- 面试进行中
        'Accepted',     -- 已接受Offer
        'Rejected',     -- 未通过
        'Onboarded',    -- 已入职
        'Withdrawn'     -- 候选人主动放弃
    ) DEFAULT 'Assessing', -- 求职申请流转阶段

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE schedule (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT, -- 日程唯一标识
    employee_id INT NOT NULL, -- 关联的员工ID
    
    content TEXT, -- 日程内容描述
    
    start_datetime DATETIME NOT NULL, -- 日程开始时间
    end_datetime DATETIME NOT NULL, -- 日程结束时间

    schedule_status ENUM(
        'Scheduled',  -- 已安排
        'Completed',  -- 已完成
        'Cancelled'   -- 已取消
    ) DEFAULT 'Scheduled', -- 日程状态

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);

CREATE TABLE interview (
    interview_id INT PRIMARY KEY AUTO_INCREMENT, -- 面试记录唯一标识
    job_application_id INT NOT NULL, -- 关联的求职申请ID

    interviewer_employee_id INT NOT NULL, -- 指派的面试官员工ID
    interview_status ENUM(
        'Scheduled',  -- 已安排
        'Completed',  -- 已完成
        'Cancelled'   -- 已取消
    ) DEFAULT 'Scheduled', -- 面试状态
    schedule_id INT NOT NULL, -- 关联的日程ID

    score DECIMAL(3, 2) CHECK (score IN (3.0, 3.25, 3.5, 3.75, 4.0)), -- 面试评分（3.0=不推荐 / 3.25=一般 / 3.5=比较推荐 / 3.75=非常推荐 / 4.0=强烈需要）
    feedback TEXT, -- 面试评价内容

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE okr (
    employee_id INT NOT NULL, -- 员工ID
    year YEAR NOT NULL, -- 所属年份
    quarter ENUM(
        'Q1', -- 第一季度
        'Q2', -- 第二季度
        'Q3', -- 第三季度
        'Q4'  -- 第四季度
    ) NOT NULL, -- 所属季度
    okr_status ENUM(
        'Goal_Setting', -- 目标制定中
        'In_Progress',  -- 执行中
        'Reviewing',    -- 复盘评审中
        'Completed'     -- 已完成评定
    ) DEFAULT 'Goal_Setting', -- OKR流转状态
    okr_objectives TEXT, -- 季度目标内容
    okr_review_summary TEXT, -- 季度末员工提交的复盘总结
    rating ENUM(
        'S', -- 对公司发展有突出贡献，年终奖系数2.0
        'A', -- 对部门业务有突出贡献，年终奖系数1.6
        'B', -- 符合预期，年终奖系数1.0
        'C'  -- 低于预期，年终奖系数0.8
    ) DEFAULT NULL, -- 绩效评级
    evaluator_employee_id INT, -- 评定人的员工ID（部门主管或其上级）
    rated_at DATETIME, -- 评定时间
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
    PRIMARY KEY (employee_id, year, quarter),
);

CREATE TABLE salary (
    employee_id INT NOT NULL, -- 员工ID
    year YEAR NOT NULL, -- 薪资所属年份
    month INT NOT NULL CHECK (month in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)), -- 薪资所属月份
    base_salary DECIMAL(12, 2) NOT NULL, -- 发放时的基本月薪快照
    overtime_pay DECIMAL(12, 2) DEFAULT 0.00, -- 加班费（三倍日薪）
    deduction_amount DECIMAL(12, 2) DEFAULT 0.00, -- 无薪假扣款金额（无薪病假/事假）
    year_end_bonus DECIMAL(12, 2) DEFAULT 0.00, -- 年终奖（仅1月发放时有值）
    final_payout DECIMAL(12, 2) NOT NULL, -- 最终税前实发总额
    payout_status ENUM(
        'Pending', -- 待发放
        'Paid'     -- 已发放
    ) DEFAULT 'Pending', -- 薪资发放状态
    paid_at DATETIME, -- 实际发放时间
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
    PRIMARY KEY (employee_id, year, month),
);

CREATE TABLE resource_request (
    resource_request_id INT PRIMARY KEY AUTO_INCREMENT, -- 资源申请唯一标识
    employee_id INT NOT NULL, -- 申请人的员工ID
    approval_request_status ENUM(
        'Supervisor_Approval', -- 直属上级审批中
        'Finance_Approval',    -- 财务部门审批中
        'Completed',           -- 审批全部通过
        'Rejected',            -- 已驳回
        'Canceled'             -- 已撤销
    ) DEFAULT 'Supervisor_Approval', -- 审批流转阶段
    category ENUM(
        'Laptop',  -- 笔记本电脑
        'Monitor', -- 显示器
        'Mobile',  -- 手机
        'Token'    -- Token额度（虚拟资产）
    ) NOT NULL, -- 申请的资源类别
    amount INT NOT NULL, -- 申请数量
    detail_description TEXT, -- 申请详情说明
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE leave_request (
    leave_request_id INT PRIMARY KEY AUTO_INCREMENT, -- 假勤申请唯一标识
    approval_request_status ENUM(
        'Supervisor_Approval', -- 直属上级审批中
        'HRBP_Approval',       -- HRBP审批中
        'Completed',           -- 审批全部通过
        'Rejected',            -- 已驳回
        'Canceled'             -- 已撤销
    ) DEFAULT 'Supervisor_Approval', -- 审批流转阶段
    leave_type ENUM(
        'Overtime',          -- 加班
        'Statutory_Annual',  -- 法定年假（5天）
        'Tenure_Annual',     -- 司龄福利年假（N天，N=入职自然年数）
        'Paid_Sick',         -- 带薪病假（5天/年）
        'Unpaid_Sick',       -- 无薪病假（不限期）
        'Unpaid_Personal',   -- 无薪事假（不限期）
        'Funeral',           -- 丧假
        'Marital',           -- 婚假
        'Paternity'          -- 陪产假
    ) NOT NULL, -- 假勤类型
    start_date DATE NOT NULL, -- 开始日期
    end_date DATE NOT NULL, -- 结束日期
    total_days INT NOT NULL CHECK (total_days >= 1), -- 总天数（最小单位为1个工作日）
    detail_description TEXT, -- 申请详情说明
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE erp_approval_round (
    approval_round_id INT PRIMARY KEY AUTO_INCREMENT, -- 审批轮次唯一标识
    approval_request_id INT NOT NULL, -- 关联的审批请求ID（资源申请或假勤申请）
    applicant_employee_id INT NOT NULL, -- 申请人的员工ID
    approver_employee_id INT NOT NULL, -- 审批人的员工ID
    round_status ENUM(
        'Pending',  -- 待审批
        'Approved', -- 已通过
        'Rejected', -- 已驳回
        'Canceled'  -- 已取消
    ) DEFAULT 'Pending', -- 本轮审批状态
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE erp_leave_balance (
    employee_id INT PRIMARY KEY, -- 员工ID
    statutory_annual_days INT DEFAULT 5, -- 法定年假剩余天数（每年5天）
    tenure_annual_days INT DEFAULT 1, -- 司龄福利年假剩余天数（入职自然年数）
    paid_sick_days INT DEFAULT 5, -- 带薪病假剩余天数（每年5天）
    year YEAR, -- 所属年份（按自然年重置）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
    PRIMARY KEY (employee_id, year),
);

-- ============================================================
-- 商业模式
-- ============================================================

CREATE TABLE customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT, -- 客户唯一标识
    name VARCHAR(100) NOT NULL, -- 客户姓名
    email VARCHAR(100) UNIQUE NOT NULL, -- 客户邮箱（唯一）
    phone VARCHAR(50) NOT NULL, -- 客户电话
    identification_number VARCHAR(100) UNIQUE NOT NULL, -- 客户身份证号（唯一）
    addresses TEXT[] DEFAULT [], -- 客户收货地址列表
    membership_tier ENUM(
        'None',       -- 无会员等级
        'Platinum',   -- 铂金会员（近6个月实付产品金额超1000刀，享10%产品折扣）
        'Black Gold'  -- 至尊会员（近6个月实付产品金额超6000刀，享20%产品折扣并免运费）
    ) DEFAULT 'None', -- 会员等级
    customer_status ENUM(
        'Active',   -- 活跃
        'Closed'    -- 已关闭
    ) DEFAULT 'Active', -- 客户状态
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE manufacturer (
    manufacturer_id INT PRIMARY KEY AUTO_INCREMENT, -- 制造商唯一标识
    name VARCHAR(100) NOT NULL, -- 制造商名称
    phone VARCHAR(50), -- 制造商联系电话
    email VARCHAR(100), -- 制造商联系邮箱
    website VARCHAR(255), -- 制造商官方网站
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE camera_sku (
    camera_sku_id INT PRIMARY KEY AUTO_INCREMENT, -- 相机SKU唯一标识
    
    brand ENUM(
        'Agfa',               -- 爱克发
        'Canon',              -- 佳能
        'Casio',              -- 卡西欧
        'Contax',             -- 康泰时
        'DJI',                -- 大疆
        'DxO Labs',           -- DxO实验室
        'Epson',              -- 爱普生
        'Fujifilm',           -- 富士
        'GoPro',              -- GoPro
        'Hasselblad',         -- 哈苏
        'Holga',              -- Holga
        'HP',                 -- 惠普
        'Kodak',              -- 柯达
        'Konica Minolta',     -- 柯尼卡美能达
        'Kyocera',            -- 京瓷
        'Leica',              -- 徕卡
        'Lytro',              -- Lytro
        'Nikon',              -- 尼康
        'OM System / Olympus', -- 奥林巴斯
        'Panasonic',          -- 松下
        'Pentax',             -- 宾得
        'Pixii',              -- Pixii
        'Ricoh',              -- 理光
        'Samsung',            -- 三星
        'Sanyo',              -- 三洋
        'SeaLife',            -- SeaLife
        'Sigma',              -- 适马
        'Sony',               -- 索尼
        'Toshiba',            -- 东芝
        'YI',                 -- 小蚁
        'Zeiss'               -- 蔡司
    ) NOT NULL, -- 相机品牌
    
    model_name TEXT, -- 型号名称

    body_type TEXT, -- 机身类型
    max_resolution TEXT, -- 最大分辨率
    effective_pixels TEXT, -- 有效像素
    sensor_size TEXT, -- 传感器尺寸
    sensor_type TEXT, -- 传感器类型
    iso TEXT, -- ISO感光度范围
    lens_mount TEXT, -- 镜头卡口类型
    focal_length_mult TEXT, -- 焦距转换系数
    articulated_lcd TEXT, -- 翻转屏类型
    screen_size TEXT, -- 屏幕尺寸
    screen_dots TEXT, -- 屏幕像素点数
    max_shutter_speed TEXT, -- 最高快门速度
    format TEXT, -- 支持的文件格式
    storage_types TEXT, -- 存储卡类型
    usb TEXT, -- USB接口类型
    weight_inc_batteries TEXT, -- 含电池重量
    dimensions TEXT, -- 机身尺寸
    gps TEXT, -- 是否支持GPS

    announced_at DATETIME, -- 发布日期
    description TEXT, -- 产品描述
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 记录创建时间
);


CREATE TABLE lens_sku (
    lens_sku_id INT PRIMARY KEY AUTO_INCREMENT, -- 镜头SKU唯一标识
    
    brand ENUM(
        'Agfa',               -- 爱克发
        'Canon',              -- 佳能
        'Casio',              -- 卡西欧
        'Contax',             -- 康泰时
        'DJI',                -- 大疆
        'DxO Labs',           -- DxO实验室
        'Epson',              -- 爱普生
        'Fujifilm',           -- 富士
        'GoPro',              -- GoPro
        'Hasselblad',         -- 哈苏
        'Holga',              -- Holga
        'HP',                 -- 惠普
        'Kodak',              -- 柯达
        'Konica Minolta',     -- 柯尼卡美能达
        'Kyocera',            -- 京瓷
        'Leica',              -- 徕卡
        'Lytro',              -- Lytro
        'Nikon',              -- 尼康
        'OM System / Olympus', -- 奥林巴斯
        'Panasonic',          -- 松下
        'Pentax',             -- 宾得
        'Pixii',              -- Pixii
        'Ricoh',              -- 理光
        'Samsung',            -- 三星
        'Sanyo',              -- 三洋
        'SeaLife',            -- SeaLife
        'Sigma',              -- 适马
        'Sony',               -- 索尼
        'Toshiba',            -- 东芝
        'YI',                 -- 小蚁
        'Zeiss',              -- 蔡司
        'Tamron',             -- 腾龙
        'Viltrox'             -- 唯卓仕
    ) NOT NULL, -- 镜头品牌
    
    model_name TEXT, -- 型号名称

    lens_type TEXT, -- 镜头类型
    focal_length TEXT, -- 焦距
    image_stab TEXT, -- 防抖功能
    lens_mount TEXT, -- 镜头卡口类型
    max_aperture TEXT, -- 最大光圈
    min_aperture TEXT, -- 最小光圈
    min_focus TEXT, -- 最近对焦距离
    weight TEXT, -- 重量
    length TEXT, -- 长度

    announced_at DATETIME, -- 发布日期
    description TEXT, -- 产品描述
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 记录创建时间
);

CREATE TABLE product (
    product_id INT PRIMARY KEY AUTO_INCREMENT, -- 商品唯一标识
    sku_type ENUM(
        'Camera', -- 相机
        'Lens'    -- 镜头
    ) NOT NULL, -- SKU类型（关联camera_sku或lens_sku）
    sku_id INT NOT NULL, -- 关联的SKU ID
    product_name VARCHAR(255) NOT NULL, -- 商品展示名称
    stock_quantity INT NOT NULL DEFAULT 1, -- 库存数量

    manufacturer_suggested_retail_price DECIMAL(12, 2) NOT NULL, -- 制造商建议零售价
    price DECIMAL(12, 2) NOT NULL, -- 当前销售价格
    is_special_offer BOOLEAN DEFAULT FALSE, -- 是否为特价商品（特价商品不享受会员折扣）
    is_returnable BOOLEAN DEFAULT TRUE, -- 是否可退货（标注为不可退货的商品不支持退货服务）

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);

CREATE TABLE order (
    order_id INT PRIMARY KEY AUTO_INCREMENT, -- 订单唯一标识
    customer_id INT NOT NULL, -- 下单客户ID

    order_status ENUM(
        'Submitted',          -- 已下单，付款尚未确认
        'Paid',               -- 已支付，待打包发货
        'Shipped',            -- 已发货，物流已产生单号
        'Delivered',          -- 已送达客户指定地点
        'Completed',          -- 已确认收货（妥投后7天自动确认）
        'Requesting_Refund',  -- 客户申请退货退款中
        'Refunded',           -- 已完成退货退款
        'Canceled'            -- 已取消（用户主动取消或超时未支付）
    ) DEFAULT 'Submitted', -- 订单流转状态
    
    product_amount DECIMAL(12, 2) NOT NULL, -- 产品费用总额
    shipping_fee DECIMAL(12, 2) DEFAULT 0.00, -- 运费
    handling_fee_when_purchased DECIMAL(12, 2) DEFAULT 0.00, -- 银行转账手续费
    total_amount DECIMAL(12, 2) NOT NULL, -- 订单应付总额（产品费用 + 运费 + 手续费）
    product_amount_refunded DECIMAL(12, 2) NOT NULL, -- 退款产品金额
    total_refund_amount DECIMAL(12, 2) NOT NULL, -- 退款总额（产品退款）
    
    paid_at DATETIME, -- 支付确认时间
    shipped_at DATETIME, -- 发货时间
    delivered_at DATETIME, -- 送达时间
    completed_at DATETIME, -- 确认收货时间
    requesting_refund_at DATETIME, -- 申请退款时间
    refunded_at DATETIME, -- 退款完成时间
    canceled_at DATETIME, -- 取消时间

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);

CREATE TABLE order_item (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT, -- 订单商品项唯一标识
    order_id INT NOT NULL, -- 关联的订单ID
    product_id INT NOT NULL, -- 关联的商品ID
    product_unit_price_snapshot DECIMAL(12, 2) NOT NULL, -- 下单时的商品单价快照
    is_special_offer_snapshot BOOLEAN, -- 下单时是否为特价商品的快照
    is_refundable_snapshot BOOLEAN, -- 下单时是否可退货的快照
    quantity INT NOT NULL, -- 购买数量

    product_total_amount DECIMAL(12, 2) NOT NULL, -- 该商品项的订单金额（单价 × 数量）
    is_refunded BOOLEAN DEFAULT FALSE, -- 是否已退货
    refunded_quantity INT DEFAULT 0, -- 已退货数量
    product_total_amount_refunded DECIMAL(12, 2) DEFAULT 0.00, -- 已退货金额

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);

CREATE TABLE payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT, -- 支付记录唯一标识
    order_id INT NOT NULL, -- 关联的订单ID

    payment_method ENUM(
        'Online',        -- 在线支付（实时到账，无手续费）
        'Bank_Transfer'  -- 银行转账（需人工确认收款，客户承担手续费）
    ) NOT NULL, -- 支付方式

    payment_status ENUM(
        'Waiting_For_Confirmation', -- 等待确认收款
        'Confirmed',                -- 已确认收款
        'Fail_To_Confirm',          -- 确认收款失败
        'Canceled'                  -- 已取消
    ) DEFAULT 'Waiting_For_Confirmation', -- 支付状态

    transaction_id VARCHAR(100), -- 第三方支付/转账流水号
    send_amount DECIMAL(12, 2) NOT NULL, -- 客户发送金额
    sender_name VARCHAR(100), -- 付款人姓名
    sender_account_number VARCHAR(100), -- 付款人账号
    receive_amount DECIMAL(12, 2) NOT NULL, -- 公司实收金额
    receiver_name VARCHAR(100) DEFAULT 'Molly Digital Inc.', -- 收款方名称
    receiver_account_number VARCHAR(100) DEFAULT '99000000000000000000000000000000', -- 收款方账号
    handling_fee DECIMAL(12, 2) DEFAULT 0.00, -- 银行转账手续费

    confirm_deadline DATETIME, -- 转账确认截止时间（下单后3个自然日）
    confirmed_by_employee_id INT, -- 确认收款的工作人员ID

    waiting_for_confirmation_at DATETIME, -- 进入等待确认状态的时间
    confirmed_at DATETIME, -- 确认收款时间
    failed_at DATETIME, -- 确认失败时间

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);

CREATE TABLE shipping (
    shipping_id INT PRIMARY KEY AUTO_INCREMENT, -- 物流记录唯一标识
    order_id INT NOT NULL, -- 关联的订单ID

    shipping_method ENUM(
        'FedEx_Standard', -- FedEx标准快递（3-5个工作日送达，运费10刀）
        'FedEx_Next_Day'  -- FedEx隔天达（14:00前发货的订单隔天17:00前送达，运费40刀）
    ) NOT NULL, -- 配送方式

    shipping_status ENUM(
        'Ordered',   -- 已下单待发货
        'Shipped',   -- 已发货
        'Delivered', -- 已送达
        'Canceled'   -- 已取消
    ) DEFAULT 'Ordered', -- 物流状态

    tracking_number VARCHAR(100), -- 物流追踪单号
    sender_name VARCHAR(100), -- 发件人姓名
    sender_phone VARCHAR(50), -- 发件人电话
    sender_address TEXT, -- 发件人地址
    receiver_name VARCHAR(100), -- 收件人姓名
    receiver_phone VARCHAR(50), -- 收件人电话
    receiver_address TEXT, -- 收件人地址

    ordered_at DATETIME, -- 下单时间
    shipped_at DATETIME, -- 发货时间
    delivered_at DATETIME, -- 送达时间
    canceled_at DATETIME, -- 取消时间

    shipping_fee DECIMAL(12, 2), -- 运费金额

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);

CREATE TABLE refund (
    refund_id INT PRIMARY KEY AUTO_INCREMENT, -- 退款记录唯一标识
    order_id INT NOT NULL, -- 关联的订单ID

    refund_type ENUM(
        'No_Reason',     -- 7天无理由退货（产品须未开封或不影响二次销售）
        'Quality_Issue'  -- 14天质量问题退货（制造缺陷或正常使用下的零部件故障）
    ) NOT NULL, -- 退货类型

    refund_status ENUM(
        'Requesting_Refund',            -- 客户已申请退货退款
        'Item_Received_and_Inspected',  -- 仓库已收到退货并完成检查
        'Passed_Inspection',            -- 检查通过，符合退货标准
        'Refunded',                     -- 已退款至原支付方式
        'Failed_Inspection'             -- 检查未通过，不符合退货标准
    ) DEFAULT 'Requesting_Refund', -- 退款流转状态
    
    inspection_notes TEXT, -- 仓库检查记录（是否影响二次销售等）

    transaction_id VARCHAR(100), -- 退款流水号
    send_amount DECIMAL(12, 2) NOT NULL, -- 公司退出金额
    sender_name VARCHAR(100) DEFAULT 'Molly Digital Inc.', -- 退款方名称
    sender_account_number VARCHAR(100) DEFAULT '99000000000000000000000000000000', -- 退款方账号
    receive_amount DECIMAL(12, 2) NOT NULL, -- 客户实收退款金额
    receiver_name VARCHAR(100) DEFAULT, -- 收款人姓名
    receiver_account_number VARCHAR(100), -- 收款人账号
    handling_fee DECIMAL(12, 2) DEFAULT 0.00, -- 因支付方式产生的手续费（由客户承担）
    
    refunded_deadline DATETIME, -- 退款截止时间（检查通过后3个自然日）
    refunded_by_employee_id INT, -- 处理退款的工作人员ID

    requesting_refund_at DATETIME, -- 客户申请退款时间
    item_received_and_inspected_at DATETIME, -- 仓库收到退货并检查完成时间
    passed_inspection_at DATETIME, -- 检查通过时间
    refunded_at DATETIME, -- 退款完成时间
    failed_inspection_at DATETIME, -- 检查未通过时间

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);

CREATE TABLE ticket (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT, -- 工单唯一标识
    customer_id INT NOT NULL, -- 提交工单的客户ID
    order_id INT, -- 关联的订单ID（可选）
    assignee_employee_id INT, -- 处理工单的客服/仓库人员的员工ID
    
    ticket_type ENUM(
        'Order',             -- 订单问题
        'Logistics',         -- 物流问题
        'Complaint',         -- 投诉
        'System_Issue',      -- 系统问题
    ) DEFAULT 'Order', -- 工单分类

    ticket_status ENUM(
        'Open',     -- 已开启，等待处理
        'Resolved', -- 已解决
        'Closed'    -- 已关闭
    ) DEFAULT 'Open', -- 工单状态

    priority ENUM(
        'Low',    -- 低优先级
        'Medium', -- 中优先级
        'High',   -- 高优先级
        'Urgent'  -- 紧急
    ) DEFAULT 'Medium', -- 工单优先级

    title VARCHAR(255) NOT NULL, -- 工单标题
    content TEXT NOT NULL, -- 客户描述的问题详情
    response TEXT NOT NULL, -- 客服回复内容

    open_at DATETIME, -- 工单开启时间
    resolved_at DATETIME, -- 工单解决时间
    closed_at DATETIME, -- 工单关闭时间

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 记录更新时间
);

CREATE TABLE email (
    email_id INT PRIMARY KEY AUTO_INCREMENT, -- 邮件唯一标识
    sender_email VARCHAR(100) NOT NULL, -- 发件人邮箱地址
    receiver_email VARCHAR(100) NOT NULL, -- 收件人邮箱地址
    cc_emails TEXT, -- 抄送邮箱地址列表
    
    subject VARCHAR(255) NOT NULL, -- 邮件主题
    body_content TEXT NOT NULL, -- 邮件正文内容

    email_status ENUM(
        'Sent', -- 已发送
    ) DEFAULT 'Sent', -- 邮件状态

    sent_at DATETIME, -- 发送时间
    revoked_at DATETIME, -- 撤回时间
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 记录创建时间
);

CREATE TABLE document (
    document_id INT PRIMARY KEY AUTO_INCREMENT, -- 文档唯一标识
    title VARCHAR(255) NOT NULL, -- 文档标题
    
    content_body LONGTEXT NOT NULL, -- 文档正文内容（支持Markdown或HTML格式）
    
    document_type ENUM(
        'Internal', -- 内部文档（仅员工可见）
        'External'  -- 外部文档（客户、会员、访客可见）
    ) NOT NULL DEFAULT 'External', -- 文档可见范围
    
    document_status ENUM(
        'Published', -- 已发布
    ) DEFAULT 'Published', -- 文档状态
    
    author_employee_id INT NOT NULL, -- 文档撰写人的员工ID

    slug VARCHAR(100) UNIQUE, -- URL友好的路径标识（如 /kb/return-policy）
    tags JSON, -- 文档标签（JSON数组，如 ["相机", "镜头"]）
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 记录创建时间
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 记录更新时间
);