CREATE DATABASE dalathasfarm;

USE dalathasfarm;

CREATE TABLE categories 
(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description VARCHAR(500),
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
    components VARCHAR(500),
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
INSERT INTO categories (name, thumbnail, description) VALUES
('Hoa cưới', 'hoa-cuoi.jpg','Những mẫu hoa cưới sang trọng, tinh tế với tông màu nhã nhặn, giúp tôn lên vẻ đẹp và ý nghĩa thiêng liêng của ngày trọng đại.'),
('Hoa chúc mừng', 'hoa-chuc-mung.jpg','Bộ sưu tập hoa chúc mừng tươi sáng, biểu trưng cho sự thành công, may mắn và niềm vui trong các dịp đặc biệt.'),
('Hoa chia buồn', 'hoa-chia-buon.jpg','Các mẫu hoa chia buồn trang nhã, thể hiện sự trân trọng và sẻ chia sâu sắc trong những thời khắc mất mát.'),
('Hoa sinh nhật', 'hoa-sinh-nhat.jpg','Hoa sinh nhật rực rỡ, đa sắc màu, mang đến niềm vui và lời chúc ý nghĩa dành cho người thân yêu.'),
('Hoa ngày lễ', 'hoa-le.jpg','Hoa tươi được thiết kế theo chủ đề các ngày lễ lớn trong năm, mang phong cách hiện đại và sang trọng.'),
('Hoa tình yêu', 'hoa-tinh-yeu.jpg','Những mẫu hoa lãng mạn với sắc đỏ – hồng chủ đạo, thay lời yêu thương gửi đến người đặc biệt.'),
('Hoa khai trương', 'hoa-khai-truong.jpg','Hoa khai trương mang ý nghĩa hồng phát – may mắn, phù hợp tặng đối tác, bạn bè trong ngày mở cửa hàng.'),
('Hoa tặng mẹ', 'hoa-tang-me.jpg','Những mẫu hoa trang nhã, ấm áp, gửi trọn tình yêu và sự biết ơn đến người mẹ yêu dấu.'),
('Hoa văn phòng', 'hoa-van-phong.jpg','Hoa trang trí văn phòng phong cách tối giản – hiện đại, mang lại cảm giác tươi mới và thanh lịch.'),
('Hoa nghệ thuật', 'hoa-nghe-thuat.jpg','Những thiết kế hoa độc đáo, sáng tạo, mang đậm chất nghệ thuật phù hợp trưng bày hoặc tặng người yêu nghệ thuật.'),
('Bó hoa cao cấp', 'hoa-cao-cap.jpg','Các bó hoa sang trọng sử dụng hoa cao cấp như hồng Ecuador, tulip, mẫu đơn, mang đẳng cấp tinh tế và khác biệt.'),
('Giỏ hoa', 'gio-hoa.jpg','Giỏ hoa thiết kế hài hòa, tỉ mỉ, phù hợp nhiều dịp như khai trương, kỷ niệm và chúc mừng. Dễ dàng vận chuyển và trưng bày.'),
('Lẵng hoa', 'lang-hoa.jpg','Lẵng hoa kích thước lớn, thể hiện tính trang trọng và sự đầu tư, thích hợp cho sự kiện, hội nghị hoặc chúc mừng quan trọng.'),
('Hoa để bàn', 'hoa-de-ban.jpg','Hoa để bàn phong cách thanh lịch, phù hợp trang trí tại nhà, văn phòng hoặc sự kiện nhỏ, tạo điểm nhấn nhẹ nhàng.'),
('Hoa nhập khẩu', 'hoa-nhap-khau.jpg','Các loại hoa nhập khẩu chất lượng cao như tulip Hà Lan, mẫu đơn châu Âu, mang vẻ đẹp sang trọng và độ bền vượt trội.'),
('Hoa cắm bình', 'hoa-cam-binh.jpg','Hoa cắm bình đa dạng phong cách, từ hiện đại đến cổ điển, mang đến vẻ đẹp nhẹ nhàng và tinh tế cho không gian sống.');

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
INSERT INTO products (supplier_id, name, price, description, stock_quantity, created_at, updated_at, category_id, occasion_id, thumbnail, components) VALUES
(3, 'Bó Hoa Hồng Trắng Pure Love', 599000, 'Bó hoa hồng trắng tinh khôi, được gói đẹp mắt và thanh lịch. Sự lựa chọn hoàn hảo để thể hiện tình yêu thuần khiết trong các dịp đặc biệt.', 15, NOW(), NOW(), 6, 3, 'purelove.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(8, 'Bó Hoa Đồng Tiền Ngại Ngùng', 769000, 'Bó hoa tone hồng nhẹ nhàng, lãng mạn, gửi gắm sự e ấp và hạnh phúc. Món quà dễ thương để bày tỏ tình cảm chân thành.', 15, NOW(), NOW(), 6, 1, 'ngai_ngung.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(2, 'Hộp Hoa Dịu Ngọt Yêu Thương', 1550000, 'Thiết kế hộp hoa cao cấp kết hợp Nến Thơm Lavender Moon, mang vẻ đẹp sang trọng và ý nghĩa tốt lành. Là tác phẩm nghệ thuật gửi trao cảm xúc yêu thương sâu lắng.', 15, NOW(), NOW(), 10, 2, 'hop_diu_ngot_713.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(9, 'Chậu Hoa Thiết Kế Tinh Khôi', 410000, 'Chậu hoa Cúc Họa Mi mang vẻ đẹp tinh khiết, trong sáng, dễ chăm sóc với độ bền cao. Phù hợp trang trí không gian sống hoặc làm quà tặng ý nghĩa.', 15, NOW(), NOW(), 14, 1, 'chau_tinh_khoi_206.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(4, 'Bó Hoa Hồng Forever', 469000, 'Bó hoa Hồng đỏ đầy lãng mạn, là món quà hoàn hảo thay lời muốn nói. Thích hợp cho Valentine, kỷ niệm hoặc sinh nhật người thương.', 15, NOW(), NOW(), 6, 1, 'hong_forever_18.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(7, 'Bó Hoa Cưới', 950000, 'Bó hoa cưới cầm tay sang trọng, thiết kế tinh tế giúp cô dâu thêm rạng rỡ. Gửi trọn thông điệp hạnh phúc và khởi đầu viên mãn.', 15, NOW(), NOW(), 1, 2, 'hoa_cuoi_050.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(1, 'Kệ Hoa Chúc Mừng', 2300000, 'Kệ hoa chúc mừng tông màu tươi sáng, hướng đến sự phát triển thuận lợi, may mắn và thành công. Thiết kế tiện lợi có thể tháo rời giỏ hoa.', 15, NOW(), NOW(), 7, 2, 'ke_chuc_mung_040.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(10, 'Kệ Hoa Chia Buồn Chốn Bình Yên', 2450000, 'Kệ hoa chia buồn tông trắng trang trọng, tinh tế. Gửi đi những lời chia sẻ, kính trọng và tình cảm chân thành trong giây phút trang nghiêm.', 15, NOW(), NOW(), 3, 2, 'ke_chia_buon_002.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(5, 'Bình Hoa Dịu Ngọt Yêu Thương', 800000, 'Bình hoa trang trí với sự kết hợp hài hòa, mang vẻ đẹp ngọt ngào và lãng mạn. Phù hợp trang trí không gian sống hoặc tặng người trân quý.', 15, NOW(), NOW(), 14, 1, 'binh_diu_ngot_351.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(6, 'Bó Hoa Yêu Thương Rực Rỡ', 740000, 'Bó hoa rực rỡ sắc màu, mang thông điệp vui vẻ, may mắn và hạnh phúc. Món quà hoàn hảo để gửi gắm tình cảm chân thành nhất.', 15, NOW(), NOW(), 2, 2, 'bo_yeu_thuong_661.jpg', 'Chi tiết sản phẩm:<br>Pure Love (Cơ bản) gồm:<br>6 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>Pure Love (Nâng Cấp) gồm:<br>12 Bông Hồng Trắng và Hoa/Lá phụ trang trí khác.<br>*Giá trên áp dụng cho bản Cơ Bản.<br>*Lưu ý: Sản phẩm làm thủ công, màu hoa có thể thay đổi theo mùa'),
(7, 'Bó Hoa Cưới', 1750000, 'Bó hoa cưới cầm tay rực rỡ và lãng mạn. Từng loại hoa mang ý nghĩa đặc biệt, là lựa chọn hoàn hảo cho ngày hạnh phúc, gửi trọn những thông điệp yêu thương.', 15, NOW(), NOW(), 1, NULL, 'hoa_cuoi_043.jpg', 'Sản phẩm bao gồm:<br>Hoa Tulip: 15 Cành<br>Hoa Tweedia: 5 Cành<br>Phụ kiện: 1 Bộ'),
(5, 'Kệ Hoa Chúc Mừng', 3000000, 'Kệ hoa chúc mừng tông đỏ rực rỡ, biểu tượng của may mắn và thịnh vượng. Thiết kế tỉ mỉ, ấn tượng, truyền tải thông điệp chúc mừng thành công và phát triển thuận lợi.', 15, NOW(), NOW(), 7, NULL, 'ke_chuc_mung_045.jpg', 'Sản phẩm bao gồm:<br>Hoa Cẩm Tú Cầu: 5 Cành<br>Rose Red Naomi Premium: 30 Cành<br>Hồng Môn: 10 Cành<br>Hoa Cúc Mẫu Đơn nhuộm: 15 Cành<br>Hoa Thủy Tiên: 10 Cành<br>Trầu Bà Nam Mỹ xịt màu: 2 Lá<br>Lá Dương Xỉ: 20 Cành<br>Lá Trầu Bà Chân Vịt xịt màu: 1 Bó<br>Kệ Vẽ + Foam + Giấy, Nơ: 1 Bộ'),
(4, 'Bó Hoa Hồng La Vie En Rose', 549000, 'Bó hoa mang gam màu pastel nhẹ nhàng, đầy trang nhã và duyên dáng. Món quà bất ngờ và hoàn hảo dành tặng người thân yêu, gia đình hoặc bạn bè.', 15, NOW(), NOW(), 6, NULL, 'lavieenrose.jpg', 'Sản phẩm bao gồm:<br>Bó Cơ Bản: 20 bông Hoa Hồng<br>Các loại Hoa và Lá phụ trang trí khác<br>*Bó Nâng Cấp: 30 bông Hoa Hồng'),
(9, 'Lan Hồ Điệp Trắng The Snowy Orchid', 722000, 'Chậu Lan Hồ Điệp 3 cành (3 head) thanh lịch, dễ chăm sóc. Mang lại vẻ đẹp sang trọng và sự tinh tế cho không gian nhà bạn. Kèm theo mẹo chăm sóc cây dễ dàng.', 15, NOW(), NOW(), 14, NULL, 'snowy_orchid.jpg', 'Sản phẩm bao gồm:<br>Cây Lan Hồ Điệp 3 cành<br>Chậu thủy tinh viền vàng<br>Rêu, cành bạch dương khô và đèn trang trí (LED)'),
(6, 'Cây Lan Ý The Peace Lily', 629000,'Cây Lan Ý đẹp mắt, dễ chăm sóc và có khả năng lọc không khí. Là món quà toàn diện, rất phù hợp với người hay quên vì cây sẽ báo hiệu khi cần nước bằng cách rũ lá.', 15, NOW(), NOW(), 14, NULL, 'peace_lily.jpg', 'Sản phẩm bao gồm:<br>Cây Lan Ý (cao khoảng 25-40cm)<br>Chậu gốm (13cm x 13.5cm)<br>Kèm theo mẹo chăm sóc cây dễ dàng'),
(10, 'Tiểu Cảnh Giáng Sinh Mini Festive Garden', 659000, 'Tiểu cảnh mini mang không khí Giáng Sinh ấm áp. Kết hợp Cyclamen đỏ, cây thông mini và thường xuân. Đặt trong hộp trồng có đèn LED lấp lánh (kèm pin).', 15, NOW(), NOW(), 5, 8, 'mini_festive_garden.jpg', 'Sản phẩm bao gồm:<br>Cyclamen đỏ (Cyclamens)<br>Cây thông mini (Mini tree)<br>Cây thường xuân (Ivy plant)<br>Hộp trồng chủ đề mùa đông (8 x 7.5 x 31.5cm)<br>Đèn LED nhấp nháy (kèm pin)'),
(8, 'Bình Hoa Thủy Tiên Rừng Đông', 700000, 'Lựa chọn hoàn hảo cho những người yêu thích làm vườn. Gồm củ hoa Thủy Tiên trắng trong chậu kim loại, kèm nón thông và cành bạch dương để trang trí theo chủ đề mùa đông.', 15, NOW(), NOW(), 14, 8, 'winter_forest_trough.jpg', 'Sản phẩm bao gồm:<br>Củ hoa Thủy Tiên trắng (Hyacinth bulbs, cao khoảng 12cm)<br>Nón thông (Pinecones) và cành bạch dương khô (birch twigs)<br>Chậu kim loại màu bạc (silver metal trough)'),
(1, 'Bó Hoa Lily Tinh Khôi', 599000, 'Bó hoa Lily được kết hợp với giấy gói hài hòa và trang nhã. Lựa chọn hoàn hảo cho ngày Valentine hoặc bất kỳ dịp đặc biệt nào.', 15, NOW(), NOW(), 6, 1, 'lily_tinhkhoi.jpg', 'Sản phẩm bao gồm:<br>Bó Cơ Bản: 5 Cành Hoa Ly Hồng<br>*Bó Nâng Cấp: 5 Cành Hoa Ly Hồng, 2 Cẩm Tú Cầu, 2 Hồng Trắng'),
(2, 'Bó Hoa Hồng True Love (99 Bông)', 1599000, 'Bó hoa sang trọng và lộng lẫy với 99 bông Hồng đỏ rực rỡ, biểu tượng của tình yêu vĩnh cửu. Món quà hoàn hảo cho Valentine hoặc kỷ niệm đặc biệt.', 15, NOW(), NOW(), 6, 1, 'truelove_99.jpg', 'Sản phẩm bao gồm:<br>99 Bông Hồng<br>*Có phiên bản Khổng Lồ: 200 Bông Hồng'),
(3, 'Kệ Hoa Chia Buồn Chốn Bình Yên', 1550000, 'Kệ hoa chia buồn tông trắng trang trọng, tinh tế. Gửi đi những lời chia sẻ từ trái tim, là biểu tượng của kính trọng và tình cảm chân thành đối với người đã khuất.', 15, NOW(), NOW(), 3, NULL, 'ke_chia_buon_011.jpg', 'Sản phẩm bao gồm:<br>Hoa Cúc Nhánh: 60 Cành<br>Hồng Môn hoặc Lily hoặc Cúc Magnum: 5 Cành<br>Lá Dương Xỉ: 20 Cành<br>Kệ + Foam, Giấy, Nơ: 1 Bộ'),
(1, 'Giỏ Hoa Tình Yêu Vĩnh Cửu', 2300000, 'Giỏ hoa lớn kết hợp Hồng Ecuador, Cẩm Tú Cầu và nhiều loại hoa sang trọng khác. Là sứ giả tinh thần hoàn hảo, gửi trao những cảm xúc yêu thương nồng ấm và vĩnh cửu.', 15, NOW(), NOW(), 12, NULL, 'gio_nong_am.jpg', 'Sản phẩm bao gồm:<br>Hoa Hồng Ecuador: 8 Cành (ngẫu nhiên)<br>Hoa Cẩm Tú Cầu: 3 Cành (ngẫu nhiên)<br>Hoa Cúc Tana: 10 Cành<br>Hoa Cát Tường: 5 Cành<br>Hoa Thủy Tiên: 10 Cành<br>Hoa Scabiosa: 10 Cành<br>Hoa Cúc Nhánh: 5 Cành<br>Lá Bạc: 1 Bó<br>Giỏ + Foam: 1 Bộ'),
(6, 'Bó Hoa Tulip Sang Trọng', 1900000, 'Bó hoa Tulip (biểu tượng của vẻ đẹp, sự thanh lịch và tình yêu hoàn hảo) được gói tinh tế. Món quà tuyệt vời để trang trí không gian hoặc gửi gắm thông điệp hạnh phúc sâu sắc.', 15, NOW(), NOW(), 11, NULL, 'bo_tulip_sang_trong.jpg', 'Sản phẩm bao gồm:<br>Hoa Tulip: 20 Cành (ngẫu nhiên)<br>Cỏ Đồng Tiền hoặc Lá phụ: 2 Cành<br>Giấy & Nơ: 1 Bộ'),
(4, 'Bó Hoa Baby Giọt Nắng', 450000, 'Bó hoa Baby (hơi thở trẻ thơ) tinh khôi, tượng trưng cho sự chân thành, thuần khiết và tình yêu thương ngây thơ. Dù đơn giản nhưng vẫn đặc biệt và sang trọng.', 15, NOW(), NOW(), 11, NULL, 'bo_baby_giot_nang.jpg', 'Sản phẩm bao gồm:<br>Hoa Baby Hasfarm: 2 Bó<br>Cỏ Đồng Tiền hoặc Lá Bạc: 2 Cành<br>Giấy & Nơ: 1 Bộ'),
(8, 'Bó Hoa Lãng Mạn Dẫn Lối Yêu Thương', 700000, 'Bó hoa kết hợp Hồng Peach Avalanche, Thủy Tiên và Cúc Tana. Gửi trao cảm xúc chân thành và sâu lắng trong tình yêu, biểu tượng của sự lãng mạn và thành công.', 15, NOW(), NOW(), 6, NULL, 'bo_dan_loi_yeu_thuong.jpg', 'Sản phẩm bao gồm:<br>Rose Peach Avalanche Premium: 5 Cành<br>Hoa Hồng Chùm: 3 Cành<br>Hoa Thủy Tiên: 5 Cành<br>Hoa Cúc Tana hoặc Baby: 5 Cành<br>Cỏ Đồng Tiền: 5 Cành<br>Hoa Cúc Nhánh: 5 Cành<br>Giấy & Nơ: 1 Bộ'),
(2, 'Bó Hoa Tulip Tinh Tế', 650000, 'Bó hoa Tulip sang trọng, tượng trưng cho vẻ đẹp và tình yêu hoàn hảo, sâu sắc. Thêm chút điểm nhấn từ Baby hoặc Tana để bó hoa thêm phần tinh tế.', 15, NOW(), NOW(), 11, NULL, 'bo_tulip_tinh_te.jpg', 'Sản phẩm bao gồm:<br>Hoa Tulip: 5 Cành (ngẫu nhiên)<br>Baby hoặc Tana: 3 Cành<br>Cỏ Đồng Tiền: 2 Cành<br>Giấy + nơ: 1 Bộ'),
(3, 'Chậu Hoa Thu Hải Đường Rực Rỡ', 170000, 'Chậu hoa Thu Hải Đường (Begonia) mang ý nghĩa độc đáo, hài hòa và thịnh vượng. Màu sắc rực rỡ, dễ chăm sóc, mang đến sự tươi mới và năng lượng tích cực.', 15, NOW(), NOW(), 14, NULL, 'chau_thuhai_duong.jpg', 'Sản phẩm bao gồm:<br>Chậu Hoa Thu Hải Đường: 1 Chậu (ngẫu nhiên)<br>Túi giấy: 1 Bộ'),
(7, 'Chậu Hoa Oải Hương Bình Yên', 160000, 'Chậu hoa Oải Hương (Lavender) nổi tiếng với hương thơm dịu dàng, biểu tượng của sự tinh khiết, tĩnh lặng và hạnh phúc. Phù hợp trang trí và cải thiện chất lượng giấc ngủ.', 15, NOW(), NOW(), 14, NULL, 'chau_lavender.jpg', 'Sản phẩm bao gồm:<br>Chậu Hoa Lavender: 1 Chậu<br>Túi & Nơ: 1 Bộ'),
(10, 'Chậu Hồng Môn Nồng Ấm', 550000, 'Chậu Hoa Hồng Môn (Anthurium) biểu tượng của tấm lòng chân thành, nồng ấm, nhiệt tình, và sự giàu có. Phù hợp trang trí không gian sống và làm việc.', 15, NOW(), NOW(), 14, NULL, 'chau_hong_mon_nong_am.jpg', 'Sản phẩm bao gồm:<br>Chậu Hoa Hồng Môn trung: 2 Chậu<br>Chậu + Đất: 1 Bộ'),
(9, 'Chậu Thường Xuân Thanh Lọc', 210000, 'Chậu Thường Xuân/Nguyệt Quế mini (Hedera), loại cây dây leo phổ biến, giúp thanh lọc không khí, giảm căng thẳng và tăng độ ẩm. Dễ chăm sóc, phù hợp với mọi không gian.', 15, NOW(), NOW(), 14, NULL, 'chau_nguyet_que.jpg', 'Sản phẩm bao gồm:<br>Chậu Cây Nguyệt Quế/ Thường Xuân mini: 2 Chậu<br>Chậu + Đất: 1 Bộ'),
(5, 'Bó Hoa Tình Yêu Dịu Dàng', 1200000, 'Bó hoa sang trọng kết hợp Hồng Sweet Avalanche, Cẩm Tú Cầu và Cẩm Chướng. Gửi trao thông điệp tình yêu lãng mạn, sự kiên cường và lòng biết ơn sâu sắc.', 15, NOW(), NOW(), 6, NULL, 'bo_diu_ngot_yeu_thuong.jpg', 'Sản phẩm bao gồm:<br>Rose Sweet Avalanche Premium: 10 Cành<br>Hoa Cẩm Tú Cầu: 2 Cành<br>Hoa Cẩm Chướng Đơn: 10 Cành<br>Hoa Cát Tường: 1 Bó<br>Hoa Delphinium hoặc Tweedia: 5 Cành<br>Lá Bạc: 1 Bó<br>Giấy & Nơ: 1 Bộ'),
(10, 'Hộp Hoa Hạnh Phúc Đong Đầy', 700000, 'Hộp hoa tươi rực rỡ, là Món Quà Hạnh Phúc, kết hợp Cẩm Chướng, Hồng Sweet Avalanche và Cúc các loại. Gửi gắm thông điệp lạc quan, niềm vui và sự gắn kết.', 15, NOW(), NOW(), 10, NULL, 'hop_hanh_phuc.jpg', 'Sản phẩm bao gồm:<br>Hoa Cẩm Chướng Đơn: 12 Cành<br>Rose Sweet Avalanche Premium: 5 Cành<br>Hoa Cúc Nhánh: 2 Cành<br>Cúc nhật nhí: 5 Cành<br>Hoa Cúc Tana: 3 Cành<br>Lá Bạc: 3 Cành<br>Phụ liệu: 1 Bộ'),
(2, 'Bình Hoa Thanh Lịch Nắng Ấm', 1500000, 'Bình hoa lớn sang trọng, kết hợp Cúc Mẫu Đơn, Hồng Chùm, Địa Lan và Calla Lily. Mang lại vẻ đẹp tinh tế, lãng mạn và lời chúc thành công, may mắn.', 15, NOW(), NOW(), 14, NULL, 'binh_nang_am.jpg', 'Sản phẩm bao gồm:<br>Hoa Cúc Mẫu Đơn nhuộm: 5 Cành<br>Hoa Hồng Chùm: 5 Cành<br>Hoa Địa Lan: 1 Cành<br>Hoa Calla Lily: 5 Cành<br>Hoa Delphinium: 5 Cành<br>Chậu Cây Môn Quan Âm: 1 Chậu<br>Lá Chanh: 5 Cành<br>Cỏ Lan Chi: 0.5 Bó<br>Bình + Foam: 1 Bộ'),
(7, 'Bó Hoa Hồng Ecuador Tinh Khôi', 1100000, 'Bó hoa Hồng Ecuador nhập khẩu kích cỡ lớn, kết hợp Cẩm Tú Cầu. Biểu tượng của tình yêu sâu lắng, lãng mạn và sự chân thành nồng ấm.', 15, NOW(), NOW(), 6, NULL, 'bo_hong_ecuador_nong_am.jpg', 'Sản phẩm bao gồm:<br>Hoa Hồng Ecuador: 3 Cành (ngẫu nhiên)<br>Hoa Cẩm Tú Cầu: 1 Cành<br>Hoa phụ ngẫu nhiên: 1 Bộ<br>Lá Bạc: 1 Bó<br>Giấy & Nơ: 1 Bộ'),
(1, 'Bó Hoa Hướng Dương Rạng Ngời', 800000, 'Bó hoa Hướng Dương rực rỡ kết hợp Hồng Peach Avalanche và Cúc Tana. Truyền tải thông điệp ấm áp, hạnh phúc, niềm vui và lòng trung thành tuyệt đối.', 15, NOW(), NOW(), 8, NULL, 'bo_huong_duong_688.jpg', 'Sản phẩm bao gồm:<br>Hoa Hướng Dương: 3 Cành<br>Rose Peach Avalanche Premium: 5 Cành<br>Hoa Cúc Tana: 10 Cành<br>Hoa Cẩm Chướng Sao: 10 Cành<br>Lá Bạc: 1 Bó<br>Giấy & nơ'),
(9, 'Kệ Hoa Khai Trương Thịnh Vượng', 3600000, 'Kệ hoa chúc mừng kích thước lớn, sang trọng. Sự kết hợp của Cẩm Tú Cầu, Hồng Sweet Avalanche và Lily Kép, biểu thị sự đoàn kết, thịnh vượng và may mắn. (Phù hợp khai trương, sự kiện lớn).', 15, NOW(), NOW(), 7, NULL, 'ke_chuc_mung_thinh_vuong.jpg','Sản phẩm bao gồm:<br>Hoa Cẩm Tú Cầu: 6 Cành<br>Rose Sweet Avalanche Premium: 30 Cành<br>Hoa Đồng Tiền: 20 Cành<br>Rose Lily - Lily Kép: 12 Cành<br>Cúc Tana: 10 Cành<br>Hoa Scabiosa: 10 Cành<br>Lá Dương Xỉ: 20 Cành<br>Trầu Bà Nam Mỹ: 5 Lá<br>Dền Rũ: 1 Cành<br>Kệ Vẽ + Foam + Giấy, Nơ: 1 Bộ'),
(5, 'Bình Hoa Chúc Mừng Lớn', 3400000, 'Bình hoa chúc mừng tông đỏ chủ đạo, mang ý nghĩa may mắn, nhiệt huyết và hân hoan. Thiết kế độc đáo, sáng tạo, là món quà tuyệt vời cho các dịp trọng đại.', 15, NOW(), NOW(), 14, NULL, 'binh_chuc_mung_lon.jpg', 'Sản phẩm bao gồm:<br>Hoa Cúc Mẫu Đơn/ Magnum nhuộm: 10 Cành<br>Hoa Hồng Ecuador: 7 Cành<br>Hoa Cúc Ping Pong: 10 Cành<br>Hoa Cát Tường: 5 Cành<br>Hoa Cẩm Tú Cầu: 4 Cành<br>Hoa Mõm Sói hoặc Phi Yến: 10 Cành<br>Lá Bạc: 2 Bó<br>Lá Dương Xỉ: 20 Cành<br>Hoa Sao Tím: 1 Bó<br>Bình + Foam: 1 Bộ'),
(8, 'Chậu Cúc Họa Mi Thuần Khiết', 260000, 'Chậu hoa Cúc Họa Mi (Marguerite) biểu tượng của sự tinh khiết, trong sáng và niềm hy vọng. Phù hợp trang trí không gian, mang lại vẻ đẹp dịu dàng, dễ chăm sóc.', 15, NOW(), NOW(), 14, NULL, 'chau_cuc_tuan_khiet.jpg', 'Sản phẩm bao gồm:<br>Chậu Hoa Cúc Họa Mi: 1 Chậu<br>Giỏ trung + Foam/Đất'),
(6, 'Chậu Hoa Hồng Nồng Ấm', 300000, 'Chậu Hoa Hồng trung, biểu tượng của tình yêu và sự lãng mạn sâu sắc. Phù hợp trang trí hoặc làm món quà hoàn hảo gửi những tình cảm tốt đẹp đến người thân.', 15, NOW(), NOW(), 14, 6, 'chau_hong_yeu_thuong.jpg', 'Sản phẩm bao gồm:<br>Chậu Hoa Hồng trung: 1 Chậu<br>Giỏ trung + Foam/Đất'),
(4, 'Kệ Hoa Chia Buồn An Yên', 2950000, 'Kệ hoa chia buồn tông trắng - tím trang trọng, tinh tế và trang nghiêm. Gửi đi những lời chia sẻ sâu sắc và lòng tôn kính, tưởng nhớ đối với người đã khuất.', 15, NOW(), NOW(), 3, NULL, 'ke_chia_buon_an_yen.jpg', 'Sản phẩm bao gồm:<br>Đồng Tiền: 60 Cành<br>Hoa Cẩm Chướng Đơn: 40 Cành<br>Hoa Cẩm Chướng Nhánh: 40 Cành<br>Hoa Calimero/ Rossi: 30 Cành<br>Hoa Cát Tường: 10 Cành<br>Hoa Cúc Nhánh: 10 Cành<br>Hoa Cúc Đơn: 20 Cành<br>Lá Dương Xỉ: 20 Cành<br>Lá Bạc: 1 Bó<br>Kệ + Foam, Giấy, Nơ: 1 Bộ'),
(5, 'Bình Hoa Cúc Tana Ánh Dương', 650000, 'Bình hoa Cúc Tana (Matricaria Vegmo Single) tươi mới, tượng trưng cho sự trong sáng, chân thành và tinh tế. Phù hợp trang trí không gian sống hoặc làm quà tặng.', 15, NOW(), NOW(), 14, NULL, 'binh_cuc_tana.jpg','Sản phẩm bao gồm:<br>Hoa Cúc Tana: 20 Cành<br>Bình: 1 Cái');

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
('Valentine Flowers', 'Giảm 15% cho tất cả các loại hoa bó và hoa hồng nhân dịp Valentine', 'Percentage', 15.00, '2025-02-01', '2025-02-15', 1),
('International Womens Day', 'Giảm 10% cho tất cả sản phẩm hoa tươi nhân ngày 8/3', 'Percentage', 10.00, '2025-03-01', '2025-03-10', 1),
('Hasfarm Anniversary', 'Giảm 20% toàn bộ sản phẩm nhân dịp kỷ niệm thành lập công ty Hasfarm', 'Percentage', 20.00, '2025-10-01', '2025-10-07', 1),
('Tet Holiday Discount', 'Giảm 30.000đ cho đơn hàng hoa chậu và cây cảnh trang trí Tết', 'Fixed_amount', 30000.00, '2025-01-20', '2025-02-05', 1),
('Mothers Day Special', 'Giảm 15% cho các bó hoa tặng mẹ', 'Percentage', 15.00, '2025-05-05', '2025-05-15', 1),
('Teachers Day Promotion', 'Giảm 10% cho hoa bó tặng thầy cô ngày 20/11', 'Percentage', 10.00, '2025-11-10', '2025-11-20', 1),
('Christmas Sale', 'Giảm 20.000đ cho sản phẩm cây thông mini và hoa trang trí Noel', 'Fixed_amount', 20000.00, '2025-12-10', '2025-12-26', 1),
('Summer Bloom', 'Giảm 20% cho hoa hướng dương và hoa cúc mùa hè', 'Percentage', 20.00, '2025-06-01', '2025-08-15', 1),
('MidYear Clearance', 'Giảm 25% cho các sản phẩm hoa tồn kho giữa năm', 'Percentage', 25.00, '2025-07-01', '2025-07-10', 1),
('Customer Appreciation', 'Giảm 10% cho tất cả đơn hàng trên 1 triệu đồng', 'Percentage', 10.00, '2025-09-01', '2025-09-30', 1),
('Black Friday', 'Giảm 35% cho tất cả sản phẩm hoa tươi trong tuần lễ Black Friday', 'Percentage', 35.00, '2025-11-25', '2025-11-30', 1),
('Cyber Monday', 'Giảm 30% cho đơn hàng online qua website Hasfarm', 'Percentage', 30.00, '2025-12-01', '2025-12-03', 1);

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

INSERT INTO product_images(id,product_id,name) VALUES
(1,1,'196c84c5-5353-4c3a-8cf1-fe731cdbbe45_2.jpg'),
(2,1,'8d73a2b2-c1df-4a91-9e1e-085c558f6c61_4.jpg'),
(3,1,'bb363a58-28ca-46ba-8af1-8754c23ea80e_5.jpg'),
(4,1,'c3029e87-f91f-4c98-8af4-c3dd30a25937_3.jpg'),
(5,1,'d751083a-33f5-41ee-a523-e88f6a6155c7_6.jpg'),
(6, 2, 'ed30a03a-abd6-4277-9ee3-d981dc775918_2.jpg'),
(7, 2, '4b00406f-54bf-4cd6-b527-9f7e2687477a_3.jpg'),
(8, 2, '157d9ab9-bf3a-4ea1-92d8-39bcda2a0abc_4.jpg'),
(9, 2, 'ed7a519e-9ce6-4216-b2c0-96e679c9dbeb_5.jpg'),
(10, 2, 'c6467f7a-b399-44da-a873-f275dfc616ef_6.jpg');

INSERT INTO users(password,fullname,phone_number,is_active,role_id) VALUES
('123456','Khách','0000000000',1,3);