PROMPT 015 – PUBLISH FINAL PRODUCT MASTER

Objective

Generate executable Snowflake SQL that publishes the current active version of the mastered product data into the FINAL layer.

This prompt implements a Business Utility (BU).

This process shall not:

* perform survivorship
* perform entity resolution
* perform matching
* perform deduplication
* perform derivations
* perform DAL logic
* generate actions

The process is responsible only for publishing the current active mastered records.

---

Output

Generate SQL for:

sql/bu/015_publish_final_product_master.sql

Generate only the SQL contents of this file.

---

Governance Inputs

Read and comply with:

* governance/001_MASTER_CONSTITUTION.md
* governance/002_APPROVED_DECISIONS_REGISTER.md
* governance/003_PROMPT_OS.md
* governance/004_PROJECT_CONTEXT.md
* governance/005_METADATA_DESIGN.md

All approved decisions are mandatory.

---

Source Table

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

---

Target Table

RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER

---

Business Context

INTM_PRODUCT_MASTER contains version history.

Only ACTIVE records represent the current mastered state.

The FINAL layer shall expose only the latest active version of each entity.

No additional business logic shall be applied.

---

Publication Rule

Publish only records where:

ACTIVE_FLAG = 'Y'

Inactive records must not be published.

Historical versions must not be published.

---

Attributes To Publish

Publish all business attributes from the active master:

ENTITY_KEY

ERP_PRODUCT_ID
SUPPLIER_PRODUCT_ID
INVENTORY_PRODUCT_ID
ECOMMERCE_PRODUCT_ID

BRAND
PRODUCT_NAME
CATEGORY
MANUFACTURER
SALE_PRICE
SIZE

DERIVED_PRODUCT_FAMILY
DERIVED_PRODUCT_GROUP
DERIVED_PRODUCT_STATUS

SOURCE_EXECUTION_REFERENCE
ACTION_SOURCE

VERSION_NO

CREATED_DTTM
UPDATED_DTTM

---

Phase 1 – Read Active Master Records

Read:

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

Filter:

ACTIVE_FLAG = 'Y'

---

Phase 2 – Publish Final Product Master

Create or replace:

RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER

using the active master records.

The FINAL layer must contain only active mastered records.

No transformations are permitted.

No attribute modifications are permitted.

No derivations are permitted.

---

Phase 3 – Validation

Validation Query 1

SELECT COUNT(*) AS FINAL_RECORD_COUNT
FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER;

Validation Query 2

SELECT COUNT(*) AS ACTIVE_MASTER_COUNT
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ACTIVE_FLAG = 'Y';

Expected Result

# FINAL_RECORD_COUNT

ACTIVE_MASTER_COUNT

---

Publication Guardrails

This process must not:

* generate CREATE actions
* generate UPDATE actions
* generate DELETE actions
* update ACTION_LOG
* modify INTM_PRODUCT_MASTER
* modify version history
* perform derivations
* perform matching
* perform survivorship

The process is publish-only.

---

Execution Flow

INTM_PRODUCT_MASTER
↓
Filter ACTIVE_FLAG = 'Y'
↓
Publish Current Master
↓
RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER

---

Success Criteria

Execution shall:

Read Active Master Records
↓
Filter Active Versions
↓
Publish Final Product Master
↓
Validate Record Counts
↓
Complete Successfully

No business logic shall be executed during publication.
