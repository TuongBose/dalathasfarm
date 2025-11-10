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
    is_active BIT DEFAULT 1,
)

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
    url VARCHAR(300) UNIQUE,
    CONSTRAINT fk_images_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE admins (
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
    profile_image VARCHAR(500) UNIQUE
);

CREATE TABLE employees (
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
    profile_image VARCHAR(500) UNIQUE
);

CREATE TABLE customers (
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
    profile_image VARCHAR(500) UNIQUE
);

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE user_roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    admin_id INT UNIQUE,
    employee_id INT UNIQUE,
    customer_id INT UNIQUE,
    CONSTRAINT fk_user_roles_roles FOREIGN KEY (role_id) REFERENCES roles(id),
    CONSTRAINT fk_user_roles_admins FOREIGN KEY (admin_id) REFERENCES admins(id),
    CONSTRAINT fk_user_roles_employees FOREIGN KEY (employee_id) REFERENCES employees(id),
    CONSTRAINT fk_user_roles_customers FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    token VARCHAR(500) UNIQUE NOT NULL,
    token_type VARCHAR(100) NOT NULL,
    expiration_date DATETIME,
    revoked BIT DEFAULT 1,
    expired BIT DEFAULT 1,
    user_role_id INT NOT NULL,
    is_mobile BIT DEFAULT 0,
    refresh_token VARCHAR(255),
    refresh_expiration_date DATETIME,
    CONSTRAINT fk_tokens_user_roles FOREIGN KEY (user_role_id) REFERENCES user_roles(id)
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
    user_role_id INT NOT NULL,
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
    CONSTRAINT fk_orders_user_roles FOREIGN KEY (user_role_id) REFERENCES user_roles(id),
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
    user_role_id INT NOT NULL,
    content VARCHAR(255) NOT NULL,
    star INT NOT NULL,
    product_id INT NOT NULL,
    created_at DATETIME,
    updated_at DATETIME,
    is_active BIT DEFAULT 0,
    is_delete BIT DEFAULT 0,
    CONSTRAINT fk_feedbacks_products FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_feedbacks_user_roles FOREIGN KEY (user_role_id) REFERENCES user_roles(id)
);

CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_role_id INT NOT NULL,
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
    CONSTRAINT fk_notifications_user_roles FOREIGN KEY (user_role_id) REFERENCES user_roles(id)
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
    user_role_id INT NOT NULL,
    import_date DATETIME NOT NULL,
    note VARCHAR(255),
    CONSTRAINT fk_purchase_orders_user_roles FOREIGN KEY (user_role_id) REFERENCES user_roles(id),
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
    user_role_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    status ENUM('Unconfirmed', 'Confirmed') DEFAULT 'Unconfirmed',
    total_money DECIMAL(10,2) NOT NULL CHECK (total_money >= 0),
    note VARCHAR(255),
    CONSTRAINT fk_supplier_orders_suppliers FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    CONSTRAINT fk_supplier_orders_user_roles FOREIGN KEY (user_role_id) REFERENCES user_roles(id)
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