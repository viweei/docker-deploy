CREATE DATABASE IF NOT EXISTS mailserver CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mailserver;

CREATE TABLE IF NOT EXISTS domains (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    domain_id INT NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE KEY,
    password VARCHAR(150) NOT NULL,
    FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS aliases (
    id INT PRIMARY KEY AUTO_INCREMENT,
    domain_id INT NOT NULL,
    source VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
);

INSERT IGNORE INTO domains(id,name) VALUES (1,'viweei.me');
-- shell:  doveadm pw -s SSHA256
-- SALT-SHA password:123456
INSERT IGNORE INTO users(domain_id, email, password) VALUES (1, 'test@viweei.me', '{SSHA256}DIVZah8U+dYHpyfgnIxUKKOejHqoQRC42dFRq/Rv4V810dsl');
