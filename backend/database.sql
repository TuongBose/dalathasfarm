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
    payment_method ENUM('Bank Transfer', 'Cash') NOT NULL,
    shipping_method ENUM('Ship', 'Pickup') NOT NULL,
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
('Lễ giáng sinh', 'christmas.jpg', '2025-11-01', '2025-12-24', 'banner_christmas.jpg', 1);

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
(1, 1, '196c84c5-5353-4c3a-8cf1-fe731cdbbe45_2.jpg'),
(2, 1, '8d73a2b2-c1df-4a91-9e1e-085c558f6c61_4.jpg'),
(3, 1, 'bb363a58-28ca-46ba-8af1-8754c23ea80e_5.jpg'),
(4, 1, 'c3029e87-f91f-4c98-8af4-c3dd30a25937_3.jpg'),
(5, 1, 'd751083a-33f5-41ee-a523-e88f6a6155c7_6.jpg'),
(6, 2, 'ed30a03a-abd6-4277-9ee3-d981dc775918_2.jpg'),
(7, 2, '4b00406f-54bf-4cd6-b527-9f7e2687477a_3.jpg'),
(8, 2, '157d9ab9-bf3a-4ea1-92d8-39bcda2a0abc_4.jpg'),
(9, 2, 'ed7a519e-9ce6-4216-b2c0-96e679c9dbeb_5.jpg'),
(10, 2, 'c6467f7a-b399-44da-a873-f275dfc616ef_6.jpg'),
(11, 3, 'a0ef9fa4-ab99-4fe4-a69c-03b5dc016583_6.jpg'),
(12, 3, 'c07085a6-0ed3-4021-ae13-838331b452e3_5.jpg'),
(13, 3, 'b9d2d4dd-31d3-4f9f-8b49-a736f9e6aa1f_3.jpg'),
(14, 3, '092ffb7d-e4fb-4917-b1dc-1c541e42445f_2.jpg'),
(15, 3, '0d478444-89e5-42ef-a9b8-a5471f6be734_1.jpg'),
(16, 4, 'edfdeb47-eb1e-4276-86e3-b922e1a38b0e_6.jpg'),
(17, 4, '29b3c6b4-137d-4103-ae49-48ca02e199ad_5.jpg'),
(18, 4, '91291a2b-45b4-439d-8eff-5fe2a42750d7_4.jpg'),
(19, 4, '2fd0096b-ead6-4d11-90a8-fbaeb797976a_3.jpg'),
(20, 4, '1eda9f64-d8b2-477b-aaca-97a6d74d9181_2.jpg'),
(21, 5, 'c751051d-95b7-4bfc-aea7-fedc048e1ae7_6.jpg'),
(22, 5, '76bb3f6d-a6eb-47b5-a9a1-ed0d55d13929_5.jpg'),
(23, 5, 'c40b3091-bd1d-4669-b483-6467b863653e_4.jpg'),
(24, 5, '9a45cb8a-1baf-462a-b9ea-a928256dfce8_2.jpg'),
(25, 5, 'c279877b-0eaf-4d5e-a2e9-d5a53970c08d_1.jpg'),
(26, 6, '4230f372-6b87-47e8-9c56-1e741e094505_6.jpg'),
(27, 6, '67291619-16f0-449b-8ed8-268dc09a4311_4.jpg'),
(28, 6, 'f53947d1-95b7-4649-bc9b-acf5cd789579_5.jpg'),
(29, 6, '71f6d772-5303-4649-afd1-c89c6eeab7b8_3.jpg'),
(30, 6, 'c5c61976-4ac4-4269-b6fa-d723bb5d4354_2.jpg'),
(31, 7, 'aeef6b01-0c0f-4349-93cc-d41bc0c9dd58_6.jpg'),
(32, 7, '88eccfe9-36aa-49de-8edb-0517b92c2924_5.jpg'),
(33, 7, '8f19e798-9f85-438b-8d84-79799cb0fc6d_4.jpg'),
(34, 7, '397267db-f741-4ad4-85d9-a1288e027899_3.jpg'),
(35, 7, 'af95afb6-dd60-4360-9270-6f4acb4f2e4e_2.jpg'),
(36, 8, '691d213d-b992-476a-a822-b9625d8b5886_5.jpg'),
(37, 8, '522012c0-de86-497b-ad10-95ba81d95359_6.jpg'),
(38, 8, '39aa7401-fb91-434f-99c7-6a05ed1bfa27_4.jpg'),
(39, 8, '754955a5-44a8-4240-b3c7-8d89783c93db_3.jpg'),
(40, 8, '7b06797f-ff0a-4886-9081-3c60d81b2237_2.jpg'),
(41, 9, '4978453f-8551-4dcb-9659-469213554f3b_6.jpg'),
(42, 9, '83e2dbfb-bbba-411b-a1b7-91a30961f3a6_5.jpg'),
(43, 9, 'e147a1a4-85eb-49bc-969c-ee40ca16bb7c_4.jpg'),
(44, 9, 'd3d98e2e-055b-455b-940f-d877ddd9ae2c_3.jpg'),
(45, 9, '165a2fb0-a8f7-49da-8081-3b02a827ea04_2.jpg'),
(46, 10, '3e3812bd-7939-44f5-8760-67a7b709aa67_6.jpg'),
(47, 10, '614a0f3c-d8d8-4659-8355-a9f412a042e7_5.jpg'),
(48, 10, 'ae27e728-515a-4dab-9f7b-06a55b2b4063_4.jpg'),
(49, 10, '9e4b8cea-9b97-4c4a-bded-762193cc595a_3.jpg'),
(50, 10, '063d1857-4bdf-431d-9a4d-f65c53a99ad8_2.jpg'),
(51, 11, '411e52ff-2d73-4abb-947b-bc7ba844773e_4.jpg'),
(52, 11, 'ad7ad4c6-7144-48aa-8010-0b216e0b2fb1_5.jpg'),
(53, 11, 'bf1bf363-25ae-4955-9084-1f87facc2575_6.jpg'),
(54, 11, '062515ad-3cce-4cee-b8c1-309c1c55f05c_3.jpg'),
(55, 11, '190a5797-05cb-470b-98ac-5c99b104d5ca_2.jpg'),
(56, 12, '7838ddb1-ae2a-4c4d-9bd3-75df616b7a0a_6.jpg'),
(57, 12, 'c1ffd85f-606d-41a3-a324-0ed8012541cc_5.jpg'),
(58, 12, '2516773f-44bb-4c1b-b3ba-76b799b2468a_4.jpg'),
(59, 12, 'd81400c7-984d-4845-b345-566c540ec8d8_3.jpg'),
(60, 12, 'aa7b981b-3fdd-4776-92f9-bdf5109bcd59_2.jpg'),
(61, 13, 'a7c3f19a-f531-45fe-bcc7-29cae4977c4f_6.jpg'),
(62, 13, '80b11fd2-3b9a-4072-8879-e97752c3258d_5.jpg'),
(63, 13, '0f4d5cbc-7dc6-4625-955e-1b6547210598_4.jpg'),
(64, 13, '67f72d46-59a5-4738-a0fd-26ccf2ec1bfe_3.jpg'),
(65, 13, 'd3792214-067f-47ea-9f54-ce1765bee8e7_2.jpg'),
(66, 14, 'b8e367ed-0406-4cb2-836e-7e1f60d0b8fb_5.jpg'),
(67, 14, '5399b187-ba26-4bb9-a31e-c3a1831aa744_6.jpg'),
(68, 14, '7307a545-1564-46f3-aa5a-44bd3b12793f_4.jpg'),
(69, 14, '2957b002-90fa-4525-9fa3-94f9f205f302_2.jpg'),
(70, 14, '8f5bccb9-30a1-472a-866f-dc192338a363_1.jpg'),
(71, 15, '0d3e3928-caf2-4de2-af92-d47f72f75702_6.jpg'),
(72, 15, '44c66fb6-e63d-4202-b79e-2b90e89b8da7_5.jpg'),
(73, 15, 'd17de45c-269f-4b78-966e-ba7d29f670bc_4.jpg'),
(74, 15, '4e1ac669-314b-4dd1-ba3f-b8716a74b97d_3.jpg'),
(75, 15, 'ff8d0947-abff-4c62-b19f-042e6f9ac93c_1.jpg'),
(76, 16, 'dcc01ccc-3c3e-4a17-8bdf-cb9291838592_6.jpg'),
(77, 16, '0e177f8e-e963-418d-84e6-719ad5905627_5.jpg'),
(78, 16, 'a288a795-0374-4379-a88b-850752af6e28_4.jpg'),
(79, 16, '1f6e94eb-2f39-4672-ba67-e3876810b8cc_3.jpg'),
(80, 16, '7b742811-d11f-4803-831c-bbc4796f1a51_1.jpg'),
(81, 17, '2a39ae2e-f13e-44b3-ae25-42fbd4ac2cfd_6.jpg'),
(82, 17, 'f66a8614-818e-40b2-a16d-df17fdad84a0_4.jpg'),
(83, 17, '5a72b95b-3a15-45dd-9574-4177412f7165_5.jpg'),
(84, 17, '8e4fd445-d347-47aa-8485-657d508906fd_3.jpg'),
(85, 17, 'd2fe9216-1a6c-477b-b3b7-a296ef9ed9dc_2.jpg'),
(86, 18, 'f1b98654-b58f-436d-b394-2079e76ea5f2_6.jpg'),
(87, 18, 'd29d38ca-26f8-4935-883c-8507dd2a5340_5.jpg'),
(88, 18, '3cea8d5b-72a5-456f-bbe0-273a6d42aeb6_4.jpg'),
(89, 18, 'c1b6e315-3383-4a45-b6bb-c1a92d54fed5_3.jpg'),
(90, 18, '8a195751-b705-441d-8e23-62fa8d90b491_1.jpg'),
(91, 19, '1933eda9-e3a0-4802-bea0-e576992fc7bf_6.jpg'),
(92, 19, '8be1cc2a-59cc-4f19-a859-20c61266ad93_5.jpg'),
(93, 19, 'f9b82db7-29dc-45c0-aac0-71d43debf434_4.jpg'),
(94, 19, '59a12e7b-0fb1-405c-9516-557ccb318e8b_3.jpg'),
(95, 19, '2eed86d2-bfa5-4f85-8456-d489d0ebae4b_2.jpg'),
(96, 20, 'f9b73e64-04be-49fe-b269-c87ab7818830_6.jpg'),
(97, 20, '2dd4b004-614d-41bd-8c11-9b738c5ee8a2_5.jpg'),
(98, 20, 'fbff18d5-bdbe-4352-a943-03774148b574_4.jpg'),
(99, 20, '2d92f349-1163-4ef3-b100-7e646f2175a6_3.jpg'),
(100, 20, '3b951eaf-7c1c-446a-99e2-e4aa8dc24594_2.jpg'),
(101, 21, 'd865bda1-7f73-4d8b-b8bd-064018a7284d_6.jpg'),
(102, 21, '948b762e-196d-45ce-b2b0-aeb2ffd2f3e0_5.jpg'),
(103, 21, 'b7e77347-145f-426c-b75d-c9105218d888_4.jpg'),
(104, 21, '9e5c56ac-3f27-493e-b96f-edd55fde3d2c_3.jpg'),
(105, 21, '56f16cab-984d-4bcf-b986-c80808584808_2.jpg'),
(106, 22, '8594b20d-c043-4f56-97b5-825219ff88de_6.jpg'),
(107, 22, 'd62b3006-fd5b-445e-9afb-892ee48862c8_5.jpg'),
(108, 22, '91f71d43-7e1c-4660-b3db-d86760413387_4.jpg'),
(109, 22, '71f0a9f8-5799-4634-a419-072a3aa612c7_3.jpg'),
(110, 22, 'f2c1eb85-5f69-40e2-923f-fd859944689e_2.jpg'),
(111, 23, '46fa601d-17ad-4bfb-b636-8e9b96ec36eb_6.jpg'),
(112, 23, '2dd6e143-397a-47a1-aeef-bc50a534599b_5.jpg'),
(113, 23, 'ee6d6a84-d754-4d5b-8b87-928975adfdcd_4.jpg'),
(114, 23, '3d91afca-ba47-4d84-8e1a-47487251e693_3.jpg'),
(115, 23, '6ac285d6-217c-4132-a05a-0ff3c3c642e4_2.jpg'),
(116, 24, '15371b4b-fe12-433b-957c-b1eaf6d255b2_5.jpg'),
(117, 24, '305b3161-cec4-41f2-a60f-fb02e55d390c_4.jpg'),
(118, 24, 'e8cf6e5b-3278-444c-b5be-7885ccea8ec0_6.jpg'),
(119, 24, '6cbcb575-a1d5-48fb-8e92-a2bd4636262f_3.jpg'),
(120, 24, '61b2455e-a726-4558-9572-8bf6e80525e5_2.jpg'),
(121, 25, '5147475b-d3c4-496f-8b3d-29d2aa8d7ce4_6.jpg'),
(122, 25, '101c87c3-63fe-4102-9724-a6786522a2f0_5.jpg'),
(123, 25, 'dcfa882e-88ef-4595-a631-093fe42cb26e_4.jpg'),
(124, 25, '73cf0903-f989-49cf-8916-49c11c893328_3.jpg'),
(125, 25, '010e3d05-ef55-4995-8682-bd35f202bd7f_2.jpg'),
(126, 26, 'c861c74d-4907-4b07-a969-0a0cc34743fd_6.jpg'),
(127, 26, '297864a9-b9e8-4b38-b85e-7c645d372d87_5.jpg'),
(128, 26, '2716767b-0369-43b6-abab-ff708e345255_4.jpg'),
(129, 26, '97d3e369-2c9e-4833-8931-e9390322d6a3_3.jpg'),
(130, 26, 'c0f9c727-c94d-42c0-85c1-6f60785b9d60_2.jpg'),
(131, 27, '58e7763c-95ca-45c0-b3c9-cea4cbba1eb8_6.jpg'),
(132, 27, 'c1f162d0-64bc-4f46-bbf8-e38c3293a984_5.jpg'),
(133, 27, '1378c898-5a5f-4181-865c-d8521ed8074d_4.jpg'),
(134, 27, '3383e480-0c23-402f-a4b5-1da8b888a8eb_3.jpg'),
(135, 27, '7d0f20ed-9de8-491d-95a8-4e42ae49da63_2.jpg'),
(136, 28, '4d453db3-bd6d-4cdd-9bee-4a575a1c3fef_6.jpg'),
(137, 28, 'aafc105e-6086-42ab-b330-c825f222994f_5.jpg'),
(138, 28, '71c2af12-b5fb-4be7-acfa-c5eb369872ab_4.jpg'),
(139, 28, '86d401ef-5117-4067-9afe-66a1997a0549_3.jpg'),
(140, 28, 'e903c549-26f9-464d-b443-321ad4f80968_2.jpg'),
(141, 29, '4958cc24-9d8c-4007-b816-3533eade1d99_5.jpg'),
(142, 29, 'd66f5f05-3338-41e1-afaf-4b9d3449b903_4.jpg'),
(143, 29, '8334244d-9efd-4169-a9af-294176dd7db1_6.jpg'),
(144, 29, '85f8678e-5cee-4e12-a4ac-cee296756662_3.jpg'),
(145, 29, '438ba80b-8681-4132-9526-4db16563848f_2.jpg'),
(146, 30, 'ecdff8ad-6224-436e-9c5a-4198264acc98_6.jpg'),
(147, 30, '324be58f-2f3c-473b-925a-4c4111155805_5.jpg'),
(148, 30, 'e8a8fe04-9969-4fa6-b7ee-355c658789ad_4.jpg'),
(149, 30, '500ae8d9-da8f-4b14-aa8b-6f2e64dc4aa4_3.jpg'),
(150, 30, 'c440e1cb-922d-4eb3-975d-a0d6a8ff3f32_2.jpg'),
(151, 31, '44add2a4-344b-42da-8f5f-25e7aedeba2b_6.jpg'),
(152, 31, '6372a949-1988-4c95-84d0-ae4d5e59bee1_5.jpg'),
(153, 31, 'e6435c36-f958-4d92-9f96-67c9c278d1b6_4.jpg'),
(154, 31, 'c5c4bc7f-a037-4157-9c5c-7112522548a4_3.jpg'),
(155, 31, 'ab82e647-49ab-494e-8998-f2745a77bf95_2.jpg'),
(156, 32, 'b2f9d932-689f-405d-aed7-e7e344dc812d_6.jpg'),
(157, 32, '570eab50-78a6-4707-a313-32ba6dacb71e_5.jpg'),
(158, 32, 'c515e803-7728-49fe-b2c8-d2ccd0e19f28_4.jpg'),
(159, 32, '031fbf73-cb52-4039-b35e-d8d2a894a6d6_3.jpg'),
(160, 32, '9f0ea839-54f9-46fa-b0c9-08c8d44e1295_2.jpg'),
(161, 33, 'f61d6463-8814-4cec-a55e-b297254dc516_5.jpg'),
(162, 33, 'ec5b7751-33b5-4ece-b19c-b0fe9cc56569_6.jpg'),
(163, 33, '584b4113-3e36-4dad-9081-dad6f87d79cd_4.jpg'),
(164, 33, '2e07aeba-04c2-48fe-8ee9-ef5e66ae332c_3.jpg'),
(165, 33, 'dc7a209c-1f33-4d88-b9df-4dead92ad285_2.jpg'),
(166, 34, '858a2834-1667-466e-855a-c3e198cf81db_6.jpg'),
(167, 34, '87105e7a-6663-4870-9895-fd20d3163f7b_5.jpg'),
(168, 34, '7505a3da-949b-484a-bf7a-3672ffc8960c_4.jpg'),
(169, 34, '810ac328-fd09-470b-b73f-1291030bfdef_3.jpg'),
(170, 34, '1784c675-f0fb-4d41-8905-ec2a4b753278_2.jpg'),
(171, 35, 'd102af2b-f9fb-45f3-ba08-d7f7e6397ce7_6.jpg'),
(172, 35, '311de4fd-1667-433d-9979-c347c59e7100_5.jpg'),
(173, 35, '97eeb6b4-63f0-4c72-935f-4faebd0f4e1a_4.jpg'),
(174, 35, 'bc0acc92-16ef-4fa0-ac16-0af87cf24662_3.jpg'),
(175, 35, 'cb63e675-e0ee-42a9-ac89-c33ece5d4547_2.jpg'),
(176, 36, '04dc126c-53ca-4730-855a-5f62a6ed29fc_6.jpg'),
(177, 36, '02e06491-81b5-427f-9ce7-3e143a8791cf_4.jpg'),
(178, 36, '82e12078-9fd0-40a9-a758-2541df6bfb02_5.jpg'),
(179, 36, 'd7c4a8a6-f896-4f5d-aeb3-7458b9f40b2b_3.jpg'),
(180, 36, '96b979a9-007b-4aa3-8598-ec6f0c3b2662_2.jpg');

INSERT INTO users(password,fullname,phone_number,is_active,role_id) VALUES
('123456','Khách','0000000000',1,3);