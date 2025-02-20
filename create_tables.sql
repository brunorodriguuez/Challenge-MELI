-- Tabla de Customer
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,  -- ID único para cada cliente
    email VARCHAR(255) NOT NULL UNIQUE,          -- Correo electrónico del cliente
    first_name VARCHAR(100),                     -- Nombre del cliente
    last_name VARCHAR(100),                      -- Apellido del cliente
    gender ENUM('M', 'F', 'O'),                  -- Sexo (M: Masculino, F: Femenino, O: Otro)
    address VARCHAR(255),                        -- Dirección del cliente
    user_type ENUM('buyer', 'seller')            -- Tipo de Usuario (Buyer , Seller)
    birth_date DATE,                             -- Fecha de nacimiento
    create_date DATE,                            -- Fecha en que el customer fue creado
    last_update DATE,                            -- Fecha en que el customer fue modificado
    phone VARCHAR(20)                            -- Teléfono del cliente
);

-- Tabla de Category
CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,  -- ID único para cada categoría
    name VARCHAR(100) NOT NULL,                  -- Nombre de la categoría
    status ENUM('active', 'inactive', 'deleted') -- Estado de la categoría (activo, inactivo, eliminado)
    path VARCHAR(255)                            -- Ruta que indica la jerarquía de la categoría
    create_date DATE,                            -- Fecha en que la categoría fue creada
    last_update DATE,                            -- Fecha en que la categoría fue modificada
);

-- Tabla de Item
CREATE TABLE Item (
    item_id INT PRIMARY KEY AUTO_INCREMENT,       -- ID único para cada ítem
    name VARCHAR(255) NOT NULL,                   -- Nombre del producto
    description TEXT,                             -- Descripción del producto
    price DECIMAL(10, 2) NOT NULL,                -- Precio del producto
    status ENUM('active', 'inactive', 'deleted'), -- Estado del producto (activo, inactivo, eliminado)
    create_date DATE,                             -- Fecha en que el producto fue creado
    last_update DATE,                             -- Fecha en que el producto fue modificado
    category_id INT,                              -- ID de la categoría asociada
    seller_id INT,                                -- ID del vendedor (customer_id)
    FOREIGN KEY (category_id) REFERENCES Category(category_id), -- Relación con Category
    FOREIGN KEY (seller_id) REFERENCES Customer(customer_id)  -- Relación con Customer
);

-- Tabla de Order
CREATE TABLE `Order` (
    order_id INT PRIMARY KEY AUTO_INCREMENT,      -- ID único para cada order
    customer_id INT,                              -- ID del comprador (customer_id)
    item_id INT,                                  -- ID del ítem comprado
    order_date DATE NOT NULL,                     -- Fecha en que se realizó la compra
    quantity INT NOT NULL,                        -- Cantidad comprada
    total_price DECIMAL(10, 2) NOT NULL,          -- Precio total de la compra
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id), -- Relación con Customer
    FOREIGN KEY (item_id) REFERENCES Item(item_id) -- Relación con Item
);
