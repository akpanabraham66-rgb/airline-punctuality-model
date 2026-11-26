-- 04_powerbi_user.sql
-- A read-only role and service user for Power BI Desktop (least privilege).
-- Power BI only reads the finished dbt tables, so this role can SELECT and nothing else.
-- Run once as ACCOUNTADMIN in Snowsight.

USE ROLE ACCOUNTADMIN;

-- The role: read-only access to the tables dbt builds
CREATE ROLE IF NOT EXISTS POWERBI_ROLE;

GRANT USAGE ON WAREHOUSE PUNCTUALITY_WH TO ROLE POWERBI_ROLE;
GRANT USAGE ON DATABASE PUNCTUALITY TO ROLE POWERBI_ROLE;
GRANT USAGE ON SCHEMA PUNCTUALITY.DBT_DEV TO ROLE POWERBI_ROLE;

-- Tables only: the facts, dimensions and marts. The staging view is not shared.
GRANT SELECT ON ALL TABLES IN SCHEMA PUNCTUALITY.DBT_DEV TO ROLE POWERBI_ROLE;
-- dbt replaces its tables on every build; future grants keep the access in place.
GRANT SELECT ON FUTURE TABLES IN SCHEMA PUNCTUALITY.DBT_DEV TO ROLE POWERBI_ROLE;

-- The user: for software, not a person. TYPE = SERVICE means no password and no MFA.
CREATE USER IF NOT EXISTS POWERBI_USER
  TYPE = SERVICE
  DEFAULT_ROLE = POWERBI_ROLE
  DEFAULT_WAREHOUSE = PUNCTUALITY_WH
  COMMENT = 'Service user for Power BI Desktop, read-only';

GRANT ROLE POWERBI_ROLE TO USER POWERBI_USER;

-- Manual step: create a key pair on a computer you control
--   openssl genrsa -out raw.pem 2048
--   openssl pkcs8 -topk8 -nocrypt -in raw.pem -out powerbi_key.p8
--   openssl rsa -in powerbi_key.p8 -pubout -out powerbi_key.pub
--   rm raw.pem
-- Then paste the public key (without its BEGIN/END lines) below.
-- The private key goes only to the computer that runs Power BI Desktop.
-- ALTER USER POWERBI_USER SET RSA_PUBLIC_KEY='<public key>';

-- Check: the fingerprint must match the one computed from powerbi_key.pub
-- DESC USER POWERBI_USER;    -- see the RSA_PUBLIC_KEY_FP row
