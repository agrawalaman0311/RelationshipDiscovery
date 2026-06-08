PROMPT 016 – SECURITY IMPLEMENTATION

Objective

Generate executable Snowflake SQL that implements the approved security architecture for the MDM platform.

This prompt implements platform security.

The implementation shall provide:

* Role Based Access Control (RBAC)
* Dynamic Data Masking

The implementation shall not provide:

* Row Access Policies
* ABAC
* OAuth
* SSO
* MFA
* External Identity Providers

Security controls must be simple, auditable and suitable for the current product master solution.

---

Output

Generate SQL for:

sql/security/016_security_implementation.sql

Generate only the SQL contents of this file.

---

Governance Inputs

Read and comply with:

* governance/001_MASTER_CONSTITUTION.md
* governance/002_APPROVED_DECISIONS_REGISTER.md
* governance/003_PROMPT_OS.md
* governance/004_PROJECT_CONTEXT.md
* governance/005_METADATA_DESIGN.md
* governance/006_SECURITY_ARCHITECTURE.md

All approved decisions are mandatory.

---

Business Context

The platform contains:

Source Systems

* ERP Product
* Supplier Product
* Inventory Product
* Ecommerce Product

Master Data Assets

* LOG.ACTION_LOG
* INTM.INTM_PRODUCT_MASTER
* FINAL.PRODUCT_MASTER

Metadata Assets

* MD.MD_ATTRIBUTE_DQ_RULES
* MD.MD_ATTRIBUTE_SURVIVORSHIP
* MD.MD_ATTRIBUTE_MAPPING

The security layer protects metadata, audit history and mastered data.

---

Security Architecture Position

Security is a first-class architecture component.

Execution sequence:

P10 Master Creation
↓
P11 DAL
↓
P12 Product Family
↓
P13 Product Group
↓
P14 Product Status
↓
P15 Publish Master
↓
P16 Security Layer
- RBAC
- Dynamic Masking
↓
Dashboard

Security controls must be applied after publication and before dashboard consumption.

---

RBAC Requirements

Implement Snowflake Role Based Access Control.

Create Roles:

* MDM_ADMIN
* MDM_DATA_STEWARD
* MDM_BUSINESS_USER
* MDM_AUDITOR

---

Role Responsibilities

MDM_ADMIN

Permissions:

* Full database access
* Metadata maintenance
* Rule maintenance
* Security administration
* Dashboard access

---

MDM_DATA_STEWARD

Permissions:

* Read metadata
* Read master data
* Read action log
* Read audit history

Restrictions:

* No DDL
* No security administration

---

MDM_BUSINESS_USER

Permissions:

* Read FINAL.PRODUCT_MASTER

Restrictions:

* No metadata access
* No action log access
* No version history access

---

MDM_AUDITOR

Permissions:

* Read metadata
* Read action log
* Read version history

Restrictions:

* No DML
* No DDL

---

Grant Requirements

Generate grants for:

Database Usage

RELATIONSHIP_DISCOVERY_DB

Schemas:

* LOG
* INTM
* FINAL
* MD

Warehouse:

* EXERCISE_WAREHOUSE

Generate:

* USAGE grants
* SELECT grants

Only where required by role responsibilities.

---

Future Object Access

All read permissions must support:

* Existing Tables
* Future Tables

Generate FUTURE grants where appropriate.

Examples:

GRANT SELECT ON FUTURE TABLES IN SCHEMA RELATIONSHIP_DISCOVERY_DB.MD
TO ROLE MDM_DATA_STEWARD;

GRANT SELECT ON FUTURE TABLES IN SCHEMA RELATIONSHIP_DISCOVERY_DB.MD
TO ROLE MDM_AUDITOR;

GRANT SELECT ON FUTURE TABLES IN SCHEMA RELATIONSHIP_DISCOVERY_DB.LOG
TO ROLE MDM_AUDITOR;

GRANT SELECT ON FUTURE TABLES IN SCHEMA RELATIONSHIP_DISCOVERY_DB.INTM
TO ROLE MDM_AUDITOR;

The implementation must include FUTURE TABLE grants for governance and audit schemas.

---

Role Hierarchy

Do not modify Snowflake system roles.

Do not grant roles to:

* SYSADMIN
* ACCOUNTADMIN
* SECURITYADMIN

Do not generate:

GRANT ROLE MDM_ADMIN TO ROLE SYSADMIN

Do not generate any grants to Snowflake system roles.

Create only application roles.

Application role inheritance is optional.

For simplicity, independent roles are preferred.

---

Dynamic Data Masking

Implement Snowflake Dynamic Masking Policies.

---

Protected Attributes

1. SALE_PRICE

Reason:

Commercially sensitive information.

---

2. SOURCE_EXECUTION_REFERENCE

Reason:

Internal execution lineage information.

---

3. ACTION_SOURCE

Reason:

Internal business rule lineage information.

Business users should not be able to view internal implementation details.

ACTION_SOURCE masking is mandatory.

---

Masking Behaviour

SALE_PRICE

Visible:

* MDM_ADMIN
* MDM_DATA_STEWARD

Masked:

* MDM_BUSINESS_USER
* MDM_AUDITOR

---

SOURCE_EXECUTION_REFERENCE

Visible:

* MDM_ADMIN
* MDM_DATA_STEWARD

Masked:

* MDM_BUSINESS_USER
* MDM_AUDITOR

---

ACTION_SOURCE

Visible:

* MDM_ADMIN
* MDM_DATA_STEWARD
* MDM_AUDITOR

Masked:

* MDM_BUSINESS_USER

---

Masking Policy Requirements

Generate masking policies for:

* SALE_PRICE
* SOURCE_EXECUTION_REFERENCE
* ACTION_SOURCE

Use CURRENT_ROLE() driven masking.

---

Policy Application Requirements

Apply masking policies to:

FINAL.PRODUCT_MASTER

Columns:

* SALE_PRICE
* SOURCE_EXECUTION_REFERENCE
* ACTION_SOURCE

---

INTM.INTM_PRODUCT_MASTER

Columns:

* SALE_PRICE
* SOURCE_EXECUTION_REFERENCE
* ACTION_SOURCE

---

Validation Requirements

Generate validation queries.

---

Validation 1

Masking Policy Assignments

Validate:

* MASK_SALE_PRICE
* MASK_SOURCE_EXECUTION_REFERENCE
* MASK_ACTION_SOURCE

Example:

SELECT *
FROM TABLE(
RELATIONSHIP_DISCOVERY_DB.INFORMATION_SCHEMA.POLICY_REFERENCES(
POLICY_NAME => 'MASK_ACTION_SOURCE'
)
);

---

Validation 2

Role Grants

Validate:

* MDM_ADMIN
* MDM_DATA_STEWARD
* MDM_BUSINESS_USER
* MDM_AUDITOR

Generate:

SHOW GRANTS TO ROLE MDM_ADMIN;
SHOW GRANTS TO ROLE MDM_DATA_STEWARD;
SHOW GRANTS TO ROLE MDM_BUSINESS_USER;
SHOW GRANTS TO ROLE MDM_AUDITOR;

---

Validation 3

Security Coverage

Validate that:

* SALE_PRICE
* SOURCE_EXECUTION_REFERENCE
* ACTION_SOURCE

are protected by masking policies.

---

Implementation Guardrails

Do not generate:

* Row Access Policies
* Secure Views
* OAuth Integrations
* MFA
* External Identity Providers
* ABAC

Implement only:

* RBAC
* Dynamic Data Masking

---

Success Criteria

Execution shall:

Create Roles
↓
Apply Grants
↓
Configure Future Grants
↓
Create Masking Policies
↓
Protect SALE_PRICE
↓
Protect SOURCE_EXECUTION_REFERENCE
↓
Protect ACTION_SOURCE
↓
Validate Security Controls
↓
Complete Successfully

The resulting platform must demonstrate:

* Least Privilege Access
* Role Based Access Control
* Dynamic Data Protection
* Auditability
* Enterprise Security Governance

Generate complete executable Snowflake SQL.
