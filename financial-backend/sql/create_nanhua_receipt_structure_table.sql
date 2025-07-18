-- 创建南华收款结构与质量表
CREATE TABLE IF NOT EXISTS nanhua_receipt_structure (
    id INT AUTO_INCREMENT PRIMARY KEY,
    period VARCHAR(7) NOT NULL COMMENT '期间 (YYYY-MM)',
    customer_name VARCHAR(100) NOT NULL COMMENT '客户属性',
    yearly_plan DECIMAL(15,2) DEFAULT 0 COMMENT '年度计划',
    current_amount DECIMAL(15,2) DEFAULT 0 COMMENT '当期金额',
    accumulated_amount DECIMAL(15,2) DEFAULT 0 COMMENT '累计金额',
    execution_progress DECIMAL(5,2) DEFAULT 0 COMMENT '执行进度(%)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_period_customer (period, customer_name),
    INDEX idx_period (period)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='南华收款结构与质量数据表';

-- 插入示例数据 (2025-06)
INSERT INTO nanhua_receipt_structure (period, customer_name, yearly_plan, current_amount, accumulated_amount, execution_progress) VALUES
('2025-06', '一包项目', 4500.00, 1155.92, 1155.92, 25.69),
('2025-06', '二包项目', 2500.00, 637.14, 637.14, 25.49),
('2025-06', '域内合作项目', 3500.00, 819.49, 819.49, 23.41),
('2025-06', '域外合作项目', 3000.00, 1790.91, 1790.91, 59.70),
('2025-06', '设备外服', 270.00, 71.82, 71.82, 26.60),
('2025-06', '新能源项目', 3000.00, 985.64, 985.64, 32.85),
('2025-06', '苏州项目', 1000.00, 475.98, 475.98, 47.60),
('2025-06', '抢修项目', 110.00, 22.96, 22.96, 20.87),
('2025-06', '运检项目', 900.00, 93.62, 93.62, 10.40),
('2025-06', '自建项目', 0.00, 0.00, 0.00, 0.00);

-- 插入示例数据 (2025-05)
INSERT INTO nanhua_receipt_structure (period, customer_name, yearly_plan, current_amount, accumulated_amount, execution_progress) VALUES
('2025-05', '一包项目', 4500.00, 800.00, 800.00, 17.78),
('2025-05', '二包项目', 2500.00, 450.00, 450.00, 18.00),
('2025-05', '域内合作项目', 3500.00, 600.00, 600.00, 17.14),
('2025-05', '域外合作项目', 3000.00, 1200.00, 1200.00, 40.00),
('2025-05', '设备外服', 270.00, 50.00, 50.00, 18.52),
('2025-05', '新能源项目', 3000.00, 700.00, 700.00, 23.33),
('2025-05', '苏州项目', 1000.00, 300.00, 300.00, 30.00),
('2025-05', '抢修项目', 110.00, 15.00, 15.00, 13.64),
('2025-05', '运检项目', 900.00, 60.00, 60.00, 6.67),
('2025-05', '自建项目', 0.00, 0.00, 0.00, 0.00);

-- 插入示例数据 (2025-04)
INSERT INTO nanhua_receipt_structure (period, customer_name, yearly_plan, current_amount, accumulated_amount, execution_progress) VALUES
('2025-04', '一包项目', 4500.00, 600.00, 600.00, 13.33),
('2025-04', '二包项目', 2500.00, 350.00, 350.00, 14.00),
('2025-04', '域内合作项目', 3500.00, 500.00, 500.00, 14.29),
('2025-04', '域外合作项目', 3000.00, 900.00, 900.00, 30.00),
('2025-04', '设备外服', 270.00, 40.00, 40.00, 14.81),
('2025-04', '新能源项目', 3000.00, 500.00, 500.00, 16.67),
('2025-04', '苏州项目', 1000.00, 200.00, 200.00, 20.00),
('2025-04', '抢修项目', 110.00, 10.00, 10.00, 9.09),
('2025-04', '运检项目', 900.00, 40.00, 40.00, 4.44),
('2025-04', '自建项目', 0.00, 0.00, 0.00, 0.00);
