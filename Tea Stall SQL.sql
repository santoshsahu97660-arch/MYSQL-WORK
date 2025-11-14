CREATE DATABASE IF NOT EXISTS food_stall;
USE food_stall;
CREATE TABLE IF NOT EXISTS menu_items (
  item_id INT AUTO_INCREMENT PRIMARY KEY,   -- unique id
  code VARCHAR(50) NOT NULL UNIQUE,         -- item ka short code, e.g. "VADA01"
  name VARCHAR(150) NOT NULL,               -- item ka naam
  price DECIMAL(8,2) NOT NULL,              -- selling price
  category VARCHAR(100),                     -- snack, drink, main, etc.
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS ingredients (
  ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  unit VARCHAR(30),         -- e.g. 'kg', 'liter', 'pcs'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS recipes (
  recipe_id INT AUTO_INCREMENT PRIMARY KEY,
  item_id INT NOT NULL,
  ingredient_id INT NOT NULL,
  qty_needed DECIMAL(10,3) NOT NULL, -- amount of ingredient needed per 1 unit of item
  FOREIGN KEY (item_id) REFERENCES menu_items(item_id),
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
CREATE TABLE IF NOT EXISTS inventory (
  inv_id INT AUTO_INCREMENT PRIMARY KEY,
  ingredient_id INT NOT NULL,
  qty DECIMAL(12,3) NOT NULL DEFAULT 0, -- available stock in unit specified
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
CREATE TABLE IF NOT EXISTS orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(60) NOT NULL UNIQUE,
  order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  status VARCHAR(30) DEFAULT 'completed' -- completed, pending, cancelled
);
CREATE TABLE IF NOT EXISTS order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  item_id INT NOT NULL,
  qty INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(8,2) NOT NULL,
  line_total DECIMAL(10,2) GENERATED ALWAYS AS (unit_price * qty) VIRTUAL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);
CREATE TABLE IF NOT EXISTS stock_transactions (
  tx_id INT AUTO_INCREMENT PRIMARY KEY,
  ingredient_id INT NOT NULL,
  change_qty DECIMAL(12,3) NOT NULL, -- + for purchase, - for usage
  tx_type VARCHAR(50), -- purchase, used_in_order, adjustment
  reference VARCHAR(150),
  tx_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
INSERT INTO menu_items (code, name, price, category) VALUES
('CHA01','Chai (Tea)', 20.00, 'Drinks'),
('SMA01','Samosa', 15.00, 'Snacks'),
('DOS01','Masala Dosa', 60.00, 'Main');
INSERT INTO ingredients (name, unit) VALUES
('Tea Leaves','gm'),
('Milk','liter'),
('Sugar','kg'),
('Wheat Flour','kg'),
('Oil','liter'),
('Potato','kg'),
('Rice','kg');
INSERT INTO recipes (item_id, ingredient_id, qty_needed) VALUES
(1, 1, 5.0),   -- chai needs 5 gm tea leaves per cup
(1, 2, 0.2),   -- 0.2 liter milk per cup
(1, 3, 0.01),  -- sugar 10 gm = 0.01 kg
(2, 4, 0.05),  -- samosa needs 50 gm flour
(2, 6, 0.08),  -- samosa needs 80 gm potato
(3, 7, 0.15),  -- dosa needs 150 gm rice
(3, 5, 0.02);  -- little oil per dosa
INSERT INTO inventory (ingredient_id, qty) VALUES
(1, 1000),  -- tea leaves 1000 gm
(2, 20),    -- milk 20 liters
(3, 5),     -- sugar 5 kg
(4, 10),    -- wheat flour 10 kg
(5, 10),    -- oil 10 liters
(6, 15),    -- potato 15 kg
(7, 20);    -- rice 20 kg

START TRANSACTION;
INSERT INTO orders (order_number, total_amount, status) VALUES ('ORD-20251114-0001', 0, 'pending');
SET @order_id = LAST_INSERT_ID();

INSERT INTO order_items (order_id, item_id, qty, unit_price) VALUES
(@order_id, 1, 2, 20.00),
(@order_id, 2, 1, 15.00);

UPDATE orders
SET total_amount = (SELECT SUM(line_total) FROM order_items WHERE order_id = @order_id),
    status = 'completed'
WHERE order_id = @order_id;

UPDATE inventory SET qty = qty - 10 WHERE ingredient_id = 1;
INSERT INTO stock_transactions (ingredient_id, change_qty, tx_type, reference) VALUES (1, -10, 'used_in_order', 'ORD-20251114-0001');

UPDATE inventory SET qty = qty - 0.4 WHERE ingredient_id = 2;
INSERT INTO stock_transactions (ingredient_id, change_qty, tx_type, reference) VALUES (2, -0.4, 'used_in_order', 'ORD-20251114-0001');

UPDATE inventory SET qty = qty - 0.05 WHERE ingredient_id = 4;
INSERT INTO stock_transactions (ingredient_id, change_qty, tx_type, reference) VALUES (4, -0.05, 'used_in_order', 'ORD-20251114-0001');

UPDATE inventory SET qty = qty - 0.08 WHERE ingredient_id = 6;
INSERT INTO stock_transactions (ingredient_id, change_qty, tx_type, reference) VALUES (6, -0.08, 'used_in_order', 'ORD-20251114-0001');

COMMIT;


SELECT * FROM menu_items ORDER BY category, name;

SELECT i.ingredient_id, ing.name, i.qty, ing.unit
FROM inventory i JOIN ingredients ing ON i.ingredient_id = ing.ingredient_id
ORDER BY i.qty ASC;

SELECT DATE(order_time) AS day, SUM(total_amount) AS sales, COUNT(order_id) AS orders_count
FROM orders
WHERE order_time >= CURDATE() - INTERVAL 7 DAY
GROUP BY DATE(order_time)
ORDER BY day;
SELECT * FROM menu_items;

