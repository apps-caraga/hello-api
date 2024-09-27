--
-- File generated with SQLiteStudio v3.4.4 on Fri Sep 27 17:39:35 2024
--
-- Text encoding used: System
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: audit_log
DROP TABLE IF EXISTS audit_log;

CREATE TABLE IF NOT EXISTS audit_log (
    id             INTEGER  PRIMARY KEY AUTOINCREMENT,
    table_name     TEXT     NOT NULL,
    action_type    TEXT     NOT NULL,
    row_id         INTEGER,
    changed_fields TEXT,
    old_value      TEXT,
    new_value      TEXT,
    timestamp      DATETIME DEFAULT (datetime('now', 'localtime') ) 
                            NOT NULL
);


-- Table: offices
DROP TABLE IF EXISTS offices;

CREATE TABLE IF NOT EXISTS offices (
    id              INTEGER  PRIMARY KEY AUTOINCREMENT,
    office_nickname TEXT (6) UNIQUE,
    office_name     TEXT     UNIQUE
                             NOT NULL,
    created_at      DATETIME NOT NULL
                             DEFAULT (CURRENT_TIMESTAMP) 
);

INSERT INTO offices (id, office_nickname, office_name, created_at) VALUES (1, 'PPD', 'Policy and Plans Division', '2024-04-15 11:00:20');
INSERT INTO offices (id, office_nickname, office_name, created_at) VALUES (2, 'FMD', 'Financial Management Division', '2024-04-15 11:00:50');
INSERT INTO offices (id, office_nickname, office_name, created_at) VALUES (3, '4Ps', 'Pantawid Pamilyang Pilipino Program Division', '2024-04-15 11:05:07');
INSERT INTO offices (id, office_nickname, office_name, created_at) VALUES (4, 'ProtSD', 'Protective Services Division', '2024-04-15 11:12:31');

-- Table: permissions
DROP TABLE IF EXISTS permissions;

CREATE TABLE IF NOT EXISTS permissions (
    id              INTEGER  PRIMARY KEY AUTOINCREMENT,
    permission_name TEXT,
    created_at      DATETIME NOT NULL
                             DEFAULT (datetime('now', 'localtime') ),
    updated_at      DATETIME
);

INSERT INTO permissions (id, permission_name, created_at, updated_at) VALUES (1, 'READ', '2024-09-25 12:00:26', NULL);
INSERT INTO permissions (id, permission_name, created_at, updated_at) VALUES (2, 'WRITE', '2024-09-25 12:00:32', NULL);
INSERT INTO permissions (id, permission_name, created_at, updated_at) VALUES (3, 'DELETE', '2024-09-25 12:00:39', '2024-09-25 12:02:14');
INSERT INTO permissions (id, permission_name, created_at, updated_at) VALUES (4, 'MANAGE-USERS', '2024-09-25 12:58:09', NULL);

-- Table: reports
DROP TABLE IF EXISTS reports;

CREATE TABLE IF NOT EXISTS reports (
    id         INTEGER  PRIMARY KEY AUTOINCREMENT,
    subject    TEXT     UNIQUE
                        NOT NULL,
    content    TEXT     NOT NULL,
    office_id  INTEGER  REFERENCES offices (id),
    created_by INTEGER  REFERENCES users (id) 
                        NOT NULL,
    created_at DATETIME NOT NULL
                        DEFAULT (CURRENT_TIMESTAMP),
    updated_at DATETIME
);

INSERT INTO reports (id, subject, content, office_id, created_by, created_at, updated_at) VALUES (1, 'hello', 'worldworld', 1, 1, '2024-09-25 05:09:34', NULL);
INSERT INTO reports (id, subject, content, office_id, created_by, created_at, updated_at) VALUES (2, 'Third Quarter Report 24', 'Whispers through the trees,Autumn leaves dance to the ground,Nature''s quiet breath. ', 1, 1, '2024-09-26 02:01:11', NULL);

-- Table: role_permissions
DROP TABLE IF EXISTS role_permissions;

CREATE TABLE IF NOT EXISTS role_permissions (
    id            INTEGER  PRIMARY KEY AUTOINCREMENT,
    role_id       INTEGER  REFERENCES roles (id),
    permission_id INTEGER  REFERENCES permissions (id),
    created_at    DATETIME NOT NULL
                           DEFAULT (datetime('now', 'localtime') ),
    updated_at    DATETIME
);

INSERT INTO role_permissions (id, role_id, permission_id, created_at, updated_at) VALUES (1, 1, 1, '2024-09-25 12:05:43', NULL);
INSERT INTO role_permissions (id, role_id, permission_id, created_at, updated_at) VALUES (2, 1, 2, '2024-09-25 12:05:53', NULL);
INSERT INTO role_permissions (id, role_id, permission_id, created_at, updated_at) VALUES (3, 1, 3, '2024-09-25 12:06:00', NULL);
INSERT INTO role_permissions (id, role_id, permission_id, created_at, updated_at) VALUES (4, 1, 4, '2024-09-25 12:59:02', NULL);

-- Table: roles
DROP TABLE IF EXISTS roles;

CREATE TABLE IF NOT EXISTS roles (
    id         INTEGER  PRIMARY KEY AUTOINCREMENT,
    role_name  TEXT     UNIQUE
                        NOT NULL,
    created_at DATETIME NOT NULL
                        DEFAULT (CURRENT_TIMESTAMP) 
);

INSERT INTO roles (id, role_name, created_at) VALUES (1, 'ADMIN', '2024-04-15 10:53:37');
INSERT INTO roles (id, role_name, created_at) VALUES (2, 'USER', '2024-04-15 10:53:37');

-- Table: users
DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users (
    id             INTEGER  PRIMARY KEY AUTOINCREMENT,
    username       TEXT     UNIQUE
                            NOT NULL,
    password       TEXT     NOT NULL,
    role_id        INTEGER  REFERENCES roles (id),
    key_updated_at DATETIME DEFAULT (CURRENT_TIMESTAMP) 
                            NOT NULL,
    access_key     TEXT     NOT NULL
                            DEFAULT (hex(randomblob(16) ) ),
    office_id      INTEGER  REFERENCES offices (id),
    created_at     DATETIME NOT NULL
                            DEFAULT (CURRENT_TIMESTAMP),
    updated_at     DATETIME
);

INSERT INTO users (id, username, password, role_id, key_updated_at, access_key, office_id, created_at, updated_at) VALUES (1, 'jaleonardo', '$2y$10$TBxfnaonFUUm6EEw1idRxuec4jg82FUn1ZO7d4kXH67nJWsJ9XUWu', 1, '2024-09-25 03:53:53', '323B50AFD01A87F1C8F2693374B36342', 1, '2024-09-25 03:53:53', '2024-09-25 03:54:07');

-- Trigger: RESET_ACCESS_KEY
DROP TRIGGER IF EXISTS RESET_ACCESS_KEY;
CREATE TRIGGER IF NOT EXISTS RESET_ACCESS_KEY
                       AFTER UPDATE OF key_updated_at
                          ON users
BEGIN
    UPDATE users
       SET access_key = hex(randomblob(16) ) 
     WHERE id = OLD.id;
END;


-- Trigger: SET_PERMISSION_UPDATED_AT
DROP TRIGGER IF EXISTS SET_PERMISSION_UPDATED_AT;
CREATE TRIGGER IF NOT EXISTS SET_PERMISSION_UPDATED_AT
                       AFTER UPDATE OF permission_name
                          ON permissions
BEGIN
    UPDATE permissions
       SET updated_at = datetime('now', 'localtime') 
     WHERE id = old.id;
END;


-- Trigger: SET_REPORTS_UPDATED_AT
DROP TRIGGER IF EXISTS SET_REPORTS_UPDATED_AT;
CREATE TRIGGER IF NOT EXISTS SET_REPORTS_UPDATED_AT
                       AFTER UPDATE OF subject,
                                       content
                          ON reports
BEGIN
    UPDATE reports
       SET updated_at = datetime('now', 'localtime') 
     WHERE id = old.id;
END;


-- Trigger: SET_ROLE_PERMISSION_UPDATED_AT
DROP TRIGGER IF EXISTS SET_ROLE_PERMISSION_UPDATED_AT;
CREATE TRIGGER IF NOT EXISTS SET_ROLE_PERMISSION_UPDATED_AT
                       AFTER UPDATE OF role_id,
                                       permission_id
                          ON role_permissions
BEGIN
    UPDATE role_permissions
       SET updated_at = datetime('now', 'localtime') 
     WHERE id = old.id;
END;


-- Trigger: SET_UPDATED_AT
DROP TRIGGER IF EXISTS SET_UPDATED_AT;
CREATE TRIGGER IF NOT EXISTS SET_UPDATED_AT
                       AFTER UPDATE OF password,
                                       role_id
                          ON users
BEGIN
    UPDATE users
       SET updated_at = CURRENT_TIMESTAMP
     WHERE id = OLD.id;
END;


-- View: active_users
DROP VIEW IF EXISTS active_users;
CREATE VIEW IF NOT EXISTS active_users AS
    SELECT u.id AS id,
           u.username,
           password,
           access_key,
           r.role_name,
           GROUP_CONCAT(p.permission_name) AS permissions,
           o.id AS office_id,
           o.office_name,
           o.office_nickname,
           unixepoch() AS logged_in_at
      FROM users u
           JOIN
           roles r ON u.role_id = r.id
           JOIN
           role_permissions rp ON rp.role_id = r.id
           JOIN
           permissions p ON rp.permission_id = p.id
           LEFT JOIN
           offices o ON o.id = u.office_id
     WHERE u.role_id IS NOT NULL AND 
           u.office_id IS NOT NULL
     GROUP BY u.id,
              u.username,
              r.role_name,
              o.office_name,
              o.office_nickname
     ORDER BY u.username;


COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
