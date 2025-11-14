CREATE DATABASE dalathasfarm;

USE dalathasfarm;

CREATE TABLE categories 
(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    thumbnail VARCHAR(300) UNIQUE
);

CREATE TABLE occasions
(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,      
    thumbnail VARCHAR(300) UNIQUE,           
    start_date DATE,                                    
    end_date DATE,                                      
    banner_image VARCHAR(255) UNIQUE,                          
    is_active BIT DEFAULT 1
);

CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description VARCHAR(500),
    stock_quantity INT CHECK (stock_quantity >= 0),
    created_at DATETIME,
    updated_at DATETIME,
    category_id INT NOT NULL,
    occasion_id INT,
    thumbnail VARCHAR(300) UNIQUE,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id),
    CONSTRAINT fk_products_occasion FOREIGN KEY (occasion_id) REFERENCES occasions(id),
    CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

CREATE TABLE product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    name VARCHAR(300) UNIQUE,
    CONSTRAINT fk_images_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    fullname VARCHAR(255),
    address VARCHAR(255),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    created_at DATETIME,
    updated_at DATETIME,
    is_active BIT DEFAULT 1,
    date_of_birth DATE,
    profile_image VARCHAR(500) UNIQUE,
    role_id INT NOT NULL,
    CONSTRAINT fk_users_roles FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    token VARCHAR(500) UNIQUE NOT NULL,
    token_type VARCHAR(100) NOT NULL,
    expiration_date DATETIME,
    revoked BIT DEFAULT 1,
    expired BIT DEFAULT 1,
    user_id INT NOT NULL,
    is_mobile BIT DEFAULT 0,
    refresh_token VARCHAR(255),
    refresh_expiration_date DATETIME,
    CONSTRAINT fk_tokens_users FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE coupons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL, 
    is_active BIT DEFAULT 1
);

CREATE TABLE coupon_conditions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_id INT NOT NULL,
    attribute VARCHAR(255) NOT NULL,
    operator VARCHAR(10) NOT NULL,
    value VARCHAR(255) NOT NULL,
    discount_amount DECIMAL(5,2) NOT NULL CHECK (discount_amount >= 0),
    CONSTRAINT fk_coupon_conditions FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    fullname VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(15) NOT NULL,
    address VARCHAR(200) NOT NULL,
    note VARCHAR(100),
    status ENUM('Pending', 'Processing', 'Shipping', 'Delivered', 'Cancelled'),  
    order_date DATE,
    total_money DECIMAL(10,2) NOT NULL CHECK (total_money >= 0),
    payment_method ENUM('Bank Transfer', 'Cash'),
    shipping_date DATE,
    is_active BIT DEFAULT 1,
    coupon_id INT,
    vnp_txn_ref VARCHAR(50),
    CONSTRAINT fk_orders_users FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_orders_coupons FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);

CREATE TABLE order_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    total_money DECIMAL(10,2) NOT NULL CHECK (total_money >= 0),
    coupon_id INT,
    CONSTRAINT fk_order_details_orders FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT fk_order_details_products FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_order_details_coupons FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);

CREATE TABLE feedbacks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content VARCHAR(255) NOT NULL,
    star INT NOT NULL,
    product_id INT NOT NULL,
    created_at DATETIME,
    updated_at DATETIME,
    is_active BIT DEFAULT 0,
    is_delete BIT DEFAULT 0,
    CONSTRAINT fk_feedbacks_products FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_feedbacks_users FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    type ENUM(
        'Low',         
        'Normal',      
        'High'         
    ) DEFAULT 'Normal',
    is_read BIT DEFAULT 0,
    created_at DATETIME,
    updated_at DATETIME,
    CONSTRAINT fk_notifications_users FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE supplier_invoices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    invoice_date DATETIME NOT NULL,
    total_money DECIMAL(10,2) NOT NULL CHECK (total_money >= 0),
    tax_amount DECIMAL(10,2) DEFAULT 0 CHECK (tax_amount >= 0),
    payment_method ENUM('Bank Transfer', 'Cash'),
    payment_status ENUM('Unpaid', 'Paid') DEFAULT 'Unpaid',
    note VARCHAR(255),
    CONSTRAINT fk_supplier_invoices_suppliers FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

CREATE TABLE supplier_invoice_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_invoice_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    total_money DECIMAL(10,2) NOT NULL CHECK (total_money >= 0),
    note VARCHAR(255),
    CONSTRAINT fk_supplier_invoice_details_supplier_invoices FOREIGN KEY (supplier_invoice_id) REFERENCES supplier_invoices(id),
    CONSTRAINT fk_supplier_invoice_details_products FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE purchase_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_invoice_id INT NOT NULL,
    user_id INT NOT NULL,
    import_date DATETIME NOT NULL,
    note VARCHAR(255),
    CONSTRAINT fk_purchase_orders_users FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_purchase_orders_supplier_invoices FOREIGN KEY (supplier_invoice_id) REFERENCES supplier_invoices(id)
);

CREATE TABLE purchase_order_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    CONSTRAINT fk_purchase_order_details_purchase_orders FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id),
    CONSTRAINT fk_purchase_order_details_products FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE supplier_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    user_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    status ENUM('Unconfirmed', 'Confirmed') DEFAULT 'Unconfirmed',
    total_money DECIMAL(10,2) NOT NULL CHECK (total_money >= 0),
    note VARCHAR(255),
    CONSTRAINT fk_supplier_orders_suppliers FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    CONSTRAINT fk_supplier_orders_users FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE supplier_order_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    total_money DECIMAL(10,2) NOT NULL CHECK (total_money >= 0),
    CONSTRAINT fk_supplier_order_details_supplier_orders FOREIGN KEY (supplier_order_id) REFERENCES supplier_orders(id),
    CONSTRAINT fk_supplier_order_details_products FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE product_discounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    discount_type ENUM('Percentage', 'Fixed_amount') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL CHECK (discount_value >= 0),
    start_date DATETIME,
    end_date DATETIME,
    is_active BIT DEFAULT 1
);

CREATE TABLE product_discount_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    product_discount_id INT NOT NULL,
    CONSTRAINT fk_product_discount_items_products FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_product_discount_items_product_discounts FOREIGN KEY (product_discount_id) REFERENCES product_discounts(id)
);

-- BẢNG DỮ LIỆU CATEGORIES
INSERT INTO categories (name, thumbnail) VALUES
('Hoa cưới', 'hoa-cuoi.jpg'),
('Hoa chúc mừng', 'hoa-chuc-mung.jpg'),
('Hoa chia buồn', 'hoa-chia-buon.jpg'),
('Hoa sinh nhật', 'hoa-sinh-nhat.jpg'),
('Hoa ngày lễ', 'hoa-le.jpg'),
('Hoa tình yêu', 'hoa-tinh-yeu.jpg'),
('Hoa khai trương', 'hoa-khai-truong.jpg'),
('Hoa tặng mẹ', 'hoa-tang-me.jpg'),
('Hoa văn phòng', 'hoa-van-phong.jpg'),
('Hoa nghệ thuật', 'hoa-nghe-thuat.jpg'),
('Bó hoa cao cấp', 'hoa-cao-cap.jpg'),
('Giỏ hoa', 'gio-hoa.jpg'),
('Lẵng hoa', 'lang-hoa.jpg'),
('Hoa để bàn', 'hoa-de-ban.jpg'),
('Hoa nhập khẩu', 'hoa-nhap-khau.jpg'),
('Hoa cắm bình', 'hoa-cam-binh.jpg');

-- BẢNG DỮ LIỆU OCCASIONS
INSERT INTO occasions (name, thumbnail, start_date, end_date, banner_image, is_active) VALUES
('Tết Dương Lịch', 'newyear.jpg', '2025-12-01', '2026-01-01', 'banner_newyear.jpg', 1),
('Tết Nguyên Đán', 'tet.jpg', '2026-01-01', '2026-02-04', 'banner_tet.jpg', 1),
('Ngày quốc tế phụ nữ', 'womenday.jpg', '2026-02-15', '2026-03-08', 'banner_womenday.jpg', 1),
('Ngày Thương binh Liệt sĩ', 'thuongbinh.jpg', '2026-06-27', '2026-07-27', 'banner_thuongbinh.jpg', 1),
('Ngày Phụ nữ Việt Nam', 'phunu.jpg', '2026-09-20', '2026-10-20', 'banner_phunu.jpg', 1),
('Ngày Nhà giáo Việt Nam', 'ngaynhagiaovietnam.jpg', '2025-10-20', '2025-11-20', 'banner_ngaynhagiaovietnam.jpg', 1),
('Lễ tạ ơn', 'thanksgiving.jpg', '2026-10-20', '2026-11-27', 'banner_thanksgiving.png', 1),
('Lễ giáng sinh', 'christmas.jpg', '2026-11-01', '2026-12-24', 'banner_christmas.jpg', 1);

-- BẢNG DỮ LIỆU SUPPLIERS
INSERT INTO suppliers (name, address, phone_number, email) VALUES
('Công ty TNHH Hoa Việt', '12 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh', '0909123456', 'contact@hoaviet.vn'),
('Công ty CP Hoa Tươi Hà Nội', '45 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', '0912345678', 'info@hoatuoihanoi.vn'),
('Công ty TNHH Lan Phương Garden', '88 Trần Phú, Đà Nẵng', '0934567890', 'sales@lanphuonggarden.vn'),
('Công ty Hoa Sen Vàng', '23 Nguyễn Văn Linh, Hải Phòng', '0945678901', 'support@hoasenvang.vn'),
('Công ty TNHH Dalat Flower', '55 Bùi Thị Xuân, Đà Lạt, Lâm Đồng', '0956789012', 'info@dalatflower.vn'),
('Công ty TNHH Hương Sắc Việt', '101 Phạm Văn Đồng, Bình Thạnh, TP.HCM', '0967890123', 'sales@huongsacviet.vn'),
('Công ty Hoa Yêu Thương', '32 Nguyễn Huệ, Quận 1, TP.HCM', '0978901234', 'hello@hoayeuthuong.vn'),
('Công ty TNHH Phong Lan Xanh', '17 Nguyễn Chí Thanh, Đà Nẵng', '0989012345', 'contact@phonglanxanh.vn'),
('Công ty CP Flower World', '08 Trần Hưng Đạo, Nha Trang', '0990123456', 'info@flowerworld.vn'),
('Công ty TNHH Vườn Hoa Cúc Trắng', '66 Võ Thị Sáu, Cần Thơ', '0908456123', 'support@hoacuctrang.vn');

-- BẢNG DỮ LIỆU PRODUCTS
INSERT INTO products (supplier_id, name, price, description, stock_quantity, created_at, updated_at, category_id, occasion_id, thumbnail) VALUES
(1, 'Bó hoa hồng đỏ Tết Nguyên Đán', 450000, 'Bó hoa hồng đỏ rực rỡ chào năm mới, biểu tượng của may mắn và thịnh vượng.', 20, NOW(), NOW(), 1, 2, 'hongdo_tet.jpg'),
(2, 'Giỏ hoa lan chúc mừng 30/4', 520000, 'Giỏ hoa lan vàng sang trọng, phù hợp tặng dịp lễ 30/4 - 1/5.', 15, NOW(), NOW(), 2, 4, 'lanvang_304.jpg'),
(3, 'Bình hoa cúc vàng Quốc khánh', 360000, 'Hoa cúc vàng tượng trưng cho niềm vui, thích hợp trang trí lễ Quốc khánh 2/9.', 25, NOW(), NOW(), 3, 7, 'cucvang_29.jpg'),
(4, 'Bó hoa ly trắng tri ân Nhà giáo', 390000, 'Hoa ly trắng thanh khiết, tặng thầy cô nhân ngày 20/11.', 18, NOW(), NOW(), 4, 8, 'lytrang_2011.jpg'),
(5, 'Bó hoa tulip hồng 20/10', 480000, 'Hoa tulip hồng nhẹ nhàng, tặng phái đẹp nhân ngày Phụ nữ Việt Nam.', 12, NOW(), NOW(), 5, 1, 'tulip_2010.jpg'),
(6, 'Giỏ hoa sen hồng tri ân 27/7', 410000, 'Hoa sen biểu tượng của lòng biết ơn, phù hợp tặng ngày Thương binh Liệt sĩ.', 14, NOW(), NOW(), 6, 2, 'senhong_277.jpg'),
(7, 'Bó hoa baby trắng Trung Thu', 270000, 'Hoa baby trắng nhẹ nhàng, thích hợp làm quà Trung Thu.', 30, NOW(), NOW(), 7, 8, 'babytrang_tt.jpg'),
(8, 'Bó hoa hướng dương chúc mừng Quốc tế Lao động', 320000, 'Hoa hướng dương tượng trưng cho năng lượng tích cực và hy vọng.', 22, NOW(), NOW(), 8, 5, 'huongduong_15.jpg'),
(9, 'Giỏ hoa đồng tiền Giỗ Tổ Hùng Vương', 300000, 'Hoa đồng tiền đỏ tượng trưng cho thành công và tôn vinh cội nguồn.', 20, NOW(), NOW(), 1, 3, 'dongtien_giotohungvuong.jpg'),
(10, 'Bó hoa cẩm chướng ấm áp Tết Dương Lịch', 340000, 'Hoa cẩm chướng mang thông điệp yêu thương và may mắn đầu năm.', 16, NOW(), NOW(), 2, 1, 'camchuong_tetduonglich.jpg');

-- BẢNG DỮ LIỆU ROLES
INSERT INTO roles (name) VALUES 
('Admin'),
('Employee'),
('Customer');

-- BẢNG DỮ LIỆU COUPONS
INSERT INTO coupons (code, is_active) VALUES
('HAS10OFF', 1),           -- Giảm 10% cho đơn hàng >= 500.000đ
('FREESHIPHCM', 1),        -- Miễn phí vận chuyển nội thành TP.HCM
('BIRTHDAY20', 1),         -- Giảm 20% nhân dịp sinh nhật KH
('NEWCUSTOMER15', 1),      -- Giảm 15% cho khách hàng mới
('VALENTINE25', 1),        -- Giảm 25% dịp Valentine
('WOMENDAY10', 1),         -- Giảm 10% dịp 8/3
('TET50', 1),              -- Giảm 50.000đ dịp Tết
('SUMMER15', 1),           -- Giảm 15% mùa hè
('AUTUMN20', 1),           -- Giảm 20% mùa thu
('BLACKFRIDAY30', 1),      -- Giảm 30% Black Friday
('CYBERMONDAY25', 1),      -- Giảm 25% Cyber Monday
('CHRISTMAS30', 1),        -- Giảm 30% Giáng sinh
('NEWYEAR40', 1),          -- Giảm 40% Năm mới
('FLOWERDAY10', 1),        -- Giảm 10% ngày của hoa 20/10
('MOTHERSDAY15', 1),       -- Giảm 15% ngày của mẹ
('FATHERSDAY10', 1),       -- Giảm 10% ngày của cha
('SPRING20', 1),           -- Giảm 20% mùa xuân
('WINTER25', 1),           -- Giảm 25% mùa đông
('FIRSTORDER30', 1),       -- Giảm 30% cho đơn hàng đầu tiên
('HASFARMANNI20', 1);      -- Giảm 20% dịp kỷ niệm thành lập Hasfarm

-- BẢNG DỮ LIỆU COUPON_CONDITIONS
INSERT INTO coupon_conditions (coupon_id, attribute, operator, value, discount_amount) VALUES
(1, 'total_money', '>=', '500000', 10.00),         -- HAS10OFF: giảm 10% khi đơn ≥ 500k
(2, 'shipping_city', '=', 'TP.HCM', 100.00),       -- FREESHIPHCM: miễn phí vận chuyển nội thành TP.HCM
(3, 'birthday_month', '=', 'current_month', 20.00),-- BIRTHDAY20: giảm 20% sinh nhật KH
(4, 'is_new_customer', '=', 'true', 15.00),        -- NEWCUSTOMER15: khách hàng mới
(5, 'occasion', '=', 'Valentine', 25.00),          -- VALENTINE25: dịp Valentine
(6, 'occasion', '=', 'Womens Day', 10.00),         -- WOMENDAY10: ngày 8/3
(7, 'occasion', '=', 'Tet Holiday', 50000.00),     -- TET50: giảm 50.000đ dịp Tết
(8, 'season', '=', 'Summer', 15.00),               -- SUMMER15: mùa hè
(9, 'season', '=', 'Autumn', 20.00),               -- AUTUMN20: mùa thu
(10, 'occasion', '=', 'Black Friday', 30.00),      -- BLACKFRIDAY30: dịp Black Friday
(11, 'occasion', '=', 'Cyber Monday', 25.00),      -- CYBERMONDAY25: Cyber Monday
(12, 'occasion', '=', 'Christmas', 30.00),         -- CHRISTMAS30: Giáng sinh
(13, 'occasion', '=', 'New Year', 40.00),          -- NEWYEAR40: Năm mới
(14, 'occasion', '=', 'Vietnamese Women Day', 10.00), -- FLOWERDAY10: 20/10
(15, 'occasion', '=', 'Mothers Day', 15.00),       -- MOTHERSDAY15: Ngày của mẹ
(16, 'occasion', '=', 'Fathers Day', 10.00),       -- FATHERSDAY10: Ngày của cha
(17, 'season', '=', 'Spring', 20.00),              -- SPRING20: mùa xuân
(18, 'season', '=', 'Winter', 25.00),              -- WINTER25: mùa đông
(19, 'is_first_order', '=', 'true', 30.00),        -- FIRSTORDER30: đơn hàng đầu tiên
(20, 'occasion', '=', 'Hasfarm Anniversary', 20.00); -- HASFARMANNI20: kỷ niệm thành lập

-- BẢNG DỮ LIỆU PRODUCT_DISCOUNTS
INSERT INTO product_discounts 
(name, description, discount_type, discount_value, start_date, end_date, is_active) VALUES
('Valentine Flowers', 'Giảm 15% cho tất cả các loại hoa bó và hoa hồng nhân dịp Valentine', 
 'Percentage', 15.00, '2025-02-01', '2025-02-15', 1),

('International Womens Day', 'Giảm 10% cho tất cả sản phẩm hoa tươi nhân ngày 8/3', 
 'Percentage', 10.00, '2025-03-01', '2025-03-10', 1),

('Hasfarm Anniversary', 'Giảm 20% toàn bộ sản phẩm nhân dịp kỷ niệm thành lập công ty Hasfarm', 
 'Percentage', 20.00, '2025-10-01', '2025-10-07', 1),

('Tet Holiday Discount', 'Giảm 30.000đ cho đơn hàng hoa chậu và cây cảnh trang trí Tết', 
 'Fixed_amount', 30000.00, '2025-01-20', '2025-02-05', 1),

('Mothers Day Special', 'Giảm 15% cho các bó hoa tặng mẹ', 
 'Percentage', 15.00, '2025-05-05', '2025-05-15', 1),

('Teachers Day Promotion', 'Giảm 10% cho hoa bó tặng thầy cô ngày 20/11', 
 'Percentage', 10.00, '2025-11-10', '2025-11-20', 1),

('Christmas Sale', 'Giảm 20.000đ cho sản phẩm cây thông mini và hoa trang trí Noel', 
 'Fixed_amount', 20000.00, '2025-12-10', '2025-12-26', 1),

('Summer Bloom', 'Giảm 20% cho hoa hướng dương và hoa cúc mùa hè', 
 'Percentage', 20.00, '2025-06-01', '2025-08-15', 1),

('MidYear Clearance', 'Giảm 25% cho các sản phẩm hoa tồn kho giữa năm', 
 'Percentage', 25.00, '2025-07-01', '2025-07-10', 1),

('Customer Appreciation', 'Giảm 10% cho tất cả đơn hàng trên 1 triệu đồng', 
 'Percentage', 10.00, '2025-09-01', '2025-09-30', 1),

('Black Friday', 'Giảm 35% cho tất cả sản phẩm hoa tươi trong tuần lễ Black Friday', 
 'Percentage', 35.00, '2025-11-25', '2025-11-30', 1),

('Cyber Monday', 'Giảm 30% cho đơn hàng online qua website Hasfarm', 
 'Percentage', 30.00, '2025-12-01', '2025-12-03', 1);

-- BẢNG DỮ LIỆU PRODUCT_DISCOUNT_ITEMS
-- GIẢ ĐỊNH 10 SẢN PHẨM TRONG BẢNG PRODUCTS
INSERT INTO product_discount_items (product_id, product_discount_id) VALUES
-- Valentine Flowers 
(1, 1), (5, 1), (7, 1),

-- International Womens Day 
(1, 2), (3, 2), (8, 2), (9, 2),

-- Hasfarm Anniversary  (toàn bộ sản phẩm)
(1, 3), (2, 3), (3, 3), (4, 3), (5, 3), (6, 3), (7, 3), (8, 3), (9, 3), (10, 3),

--  Tet Holiday Discount 
(2, 4), (4, 4), (10, 4),

--  Mothers Day Special 
(3, 5), (8, 5), (9, 5),

--  Teachers Day Promotion 
(1, 6), (3, 6), (7, 6),

--  Christmas Sale 
(10, 7), (8, 7), (9, 7),

--  Summer Bloom 
(6, 8), (3, 8),

--  MidYear Clearance 
(2, 9), (4, 9), (9, 9),

--  Customer Appreciation 
(1, 10), (2, 10), (3, 10), (4, 10), (5, 10),

--  Black Friday Sale 
(1, 11), (2, 11), (5, 11), (6, 11), (9, 11),

--  Cyber Monday 
(1, 12), (3, 12), (6, 12), (8, 12);

