-- 03_dbt_user.sql
-- A dedicated role and service user for dbt, with only the access it needs (least privilege).
-- Run once as ACCOUNTADMIN. dbt then signs in as DBT_USER with a key pair, never a password.

USE ROLE ACCOUNTADMIN;

-- The role: only what dbt needs
CREATE ROLE IF NOT EXISTS DBT_ROLE;

GRANT USAGE ON WAREHOUSE PUNCTUALITY_WH TO ROLE DBT_ROLE;
GRANT USAGE ON DATABASE PUNCTUALITY TO ROLE DBT_ROLE;
GRANT CREATE SCHEMA ON DATABASE PUNCTUALITY TO ROLE DBT_ROLE;    -- dbt creates its own development schema

GRANT USAGE ON SCHEMA PUNCTUALITY.RAW TO ROLE DBT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA PUNCTUALITY.RAW TO ROLE DBT_ROLE;    -- read RAW, never change it
GRANT SELECT ON FUTURE TABLES IN SCHEMA PUNCTUALITY.RAW TO ROLE DBT_ROLE;

GRANT ALL PRIVILEGES ON SCHEMA PUNCTUALITY.ANALYTICS TO ROLE DBT_ROLE;    -- final models are built here

-- The user: for software, not a person. TYPE = SERVICE means no password and no MFA.
CREATE USER IF NOT EXISTS DBT_USER
  TYPE = SERVICE
  DEFAULT_ROLE = DBT_ROLE
  DEFAULT_WAREHOUSE = PUNCTUALITY_WH
  COMMENT = 'Service user for dbt';

GRANT ROLE DBT_ROLE TO USER DBT_USER;
GRANT ROLE DBT_ROLE TO ROLE SYSADMIN;    -- lets admins see the tables dbt creates

-- Manual step: create a key pair on the computer that runs dbt
--   openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
--   openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
-- Then paste the public key (without its BEGIN/END lines) below. The private key never leaves that computer.
-- ALTER USER DBT_USER SET RSA_PUBLIC_KEY='<public key>';

-- Check: the fingerprint must match the one computed from rsa_key.pub
-- DESC USER DBT_USER;    -- see the RSA_PUBLIC_KEY_FP row
