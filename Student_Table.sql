CREATE DATABASE student_db;
USE student_db;
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    age INT,
    class VARCHAR(20),
    city VARCHAR(50)
);
INSERT INTO students (name, age, class, city) VALUES
('Santosh', 20, '12th', 'Mumbai'),
('Amit', 19, '11th', 'Delhi'),
('Riya', 18, '10th', 'Nagpur');
SELECT * FROM students;
DELETE FROM students
WHERE id NOT IN (
    SELECT MIN(id)
    FROM students
    GROUP BY name, age, class, city
);
SELECT * FROM students;
truncate students;
INSERT INTO students (name, age, class, city) VALUES
('Anudhan', 18, '10th', 'Indore'),
('Pooja', 19, '11th', 'Bhopal'),
('Harsh', 20, '12th', 'Raipur'),
('Mayur', 22, '16th', 'Nagpur');
SELECT*FROM students;
truncate students;
SELECT*FROM students;
INSERT INTO students (name, age, class, city) VALUES
('Anudhan', 20, '12th', 'Ballarpur'),
('Pooja', 25, '13th', 'Chattisgarh'),
('Harsh', 20, '12th', 'Raipur'),
('Mayur', 22, '16th', 'Nagpur');
SELECT*FROM students;

