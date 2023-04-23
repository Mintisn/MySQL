--mysql -h127.0.0.1 -uroot -p 123123
--6
CREATE DATABASE MyDb;
USE MyDb;
Create TABLE s(
    sno CHAR(10) PRIMARY KEY,
    name VARCHAR(32) NOT NULL,
    ID CHAR(18) UNIQUE
);
--5 
DROP DATABASE MyDb;
CREATE DATABASE MyDb;
USE MyDb;
Create TABLE hr(
    id CHAR(10) PRIMARY KEY,
    name VARCHAR(32) NOT NULL,
    mz CHAR(16) default '汉族'
);
--4 CHECK
DROP DATABASE MyDb;
CREATE DATABASE MyDb;
USE MyDb;
Create TABLE products(
    pid CHAR(10) PRIMARY KEY,
    name VARCHAR(32),
    brand CHAR(10),
    price INT,
    constraint CK_products_brand CHECK(brand in ('A','B')),
    constraint CK_products_price CHECK(price>0)
);
--3
CREATE DATABASE MyDb;
USE MyDb;
CREATE TABLE dept
(
    deptNo INT PRIMARY KEY,
    deptName VARCHAR(32)
);
CREATE TABLE staff
(
    staffNo INT PRIMARY KEY,
    staffName VARCHAR(32),
    gender CHAR(1),
    dob date,
    salary numeric(8,2),
    deptNo INT,
    CONSTRAINT FK_staff_deptNo FOREIGN KEY(deptNo) REFERENCES dept(deptNo)
);
--数据库、表与完整性约束的定义(Create)
--2
CREATE DATABASE TestDb;
USE TestDb;
CREATE TABLE t_emp
(
    id INT PRIMARY KEY,
    name VARCHAR(32),
    deptId INT,
    salary FLOAT
);
