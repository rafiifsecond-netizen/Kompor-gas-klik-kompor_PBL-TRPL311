-- KlikKompor MySQL roles and privileges
-- DEVELOPMENT ONLY. Review database name and replace password placeholders
-- outside source control before execution. Run as a DBA, not the runtime user.
--
-- This script intentionally does not DROP users or roles. It revokes the
-- existing runtime grants and replaces them with role-based grants.

CREATE ROLE IF NOT EXISTS 'kk_runtime'@'localhost';
CREATE ROLE IF NOT EXISTS 'kk_readonly'@'localhost';
CREATE ROLE IF NOT EXISTS 'kk_migrator'@'localhost';

CREATE USER IF NOT EXISTS 'klikkompor_migrator'@'localhost'
    IDENTIFIED BY 'REPLACE_WITH_MIGRATOR_PASSWORD';

REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'klikkompor_app'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`users`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`technician_profiles`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`service_categories`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`service_items`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`technician_services`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`addresses`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`orders`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`order_items`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`order_status_logs`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`payments`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`additional_costs`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`chats`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`chat_messages`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`notifications`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`reviews`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT ON `klikkompor_db`.`activity_logs`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`password_reset_tokens`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`personal_access_tokens`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`cache`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`cache_locks`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`jobs`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`job_batches`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`failed_jobs`
    TO 'kk_runtime'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `klikkompor_db`.`sessions`
    TO 'kk_runtime'@'localhost';

GRANT 'kk_runtime'@'localhost' TO 'klikkompor_app'@'localhost';
SET DEFAULT ROLE 'kk_runtime'@'localhost' TO 'klikkompor_app'@'localhost';

-- The read-only role is intentionally granted to views in Week 5 after the
-- view migration exists. It must not receive SELECT on sensitive base tables.
GRANT SELECT ON `klikkompor_db`.`v_service_catalog_public`
    TO 'kk_readonly'@'localhost';
GRANT SELECT ON `klikkompor_db`.`v_technician_public`
    TO 'kk_readonly'@'localhost';
GRANT SELECT ON `klikkompor_db`.`v_payment_operational`
    TO 'kk_readonly'@'localhost';
GRANT SELECT ON `klikkompor_db`.`v_audit_event_summary`
    TO 'kk_readonly'@'localhost';

GRANT ALL PRIVILEGES ON `klikkompor_db`.* TO 'kk_migrator'@'localhost';
GRANT 'kk_migrator'@'localhost' TO 'klikkompor_migrator'@'localhost';
SET DEFAULT ROLE 'kk_migrator'@'localhost' TO 'klikkompor_migrator'@'localhost';

-- Verify after execution:
-- SHOW GRANTS FOR 'klikkompor_app'@'localhost';
-- SHOW GRANTS FOR 'klikkompor_migrator'@'localhost';
-- SHOW GRANTS FOR 'kk_runtime'@'localhost';
