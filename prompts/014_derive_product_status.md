PROMPT 014 – DERIVE PRODUCT STATUS

Objective

Generate executable Snowflake SQL that derives DERIVED_PRODUCT_STATUS for active master records and generates UPDATE actions into ACTION_LOG.

This prompt implements a Business Rule (BR).

The BR shall not:

- perform survivorship
- perform entity resolution
- perform matching
- perform deduplication
- update the master table directly
- execute DAL logic

The BR is responsible only for deriving DERIVED_PRODUCT_STATUS and generating UPDATE actions.

--------------------------------------------------------------------------------

Output

Generate SQL for:

sql/br/014_derive_product_status.sql

Generate only the SQL contents of this file.

--------------------------------------------------------------------------------

Governance Inputs

Read and comply with:

- governance/001_MASTER_CONSTITUTION.md
- governance/002_APPROVED_DECISIONS_REGISTER.md
- governance/003_PROMPT_OS.md
- governance/004_PROJECT_CONTEXT.md
- governance/005_METADATA_DESIGN.md

All approved decisions are mandatory.

--------------------------------------------------------------------------------

Source Table

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

Filter:

ACTIVE_FLAG = 'Y'

--------------------------------------------------------------------------------

Target Table

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

--------------------------------------------------------------------------------

Attribute Ownership

This BR owns only:

DERIVED_PRODUCT_STATUS

This BR must not populate:

- DERIVED_PRODUCT_FAMILY
- DERIVED_PRODUCT_GROUP

Those attributes are owned by other Business Rules.

--------------------------------------------------------------------------------

Action Source Ownership

This BR generates actions using:

ACTION_SOURCE = 'P14_PRODUCT_STATUS'

ACTION_SOURCE identifies the business process responsible
for generating the action.

The DAL will propagate ACTION_SOURCE into
INTM_PRODUCT_MASTER version history.

This value is mandatory for all generated actions.

--------------------------------------------------------------------------------

Business Context

DERIVED_PRODUCT_GROUP is already a mastered attribute.

DERIVED_PRODUCT_STATUS shall be derived from DERIVED_PRODUCT_GROUP using a deterministic CASE statement.

The derivation must be simple, explainable and repeatable.

--------------------------------------------------------------------------------

Approved Hierarchy

CATEGORY
    ↓
DERIVED_PRODUCT_FAMILY
    ↓
DERIVED_PRODUCT_GROUP
    ↓
DERIVED_PRODUCT_STATUS

DERIVED_PRODUCT_STATUS must be derived from DERIVED_PRODUCT_GROUP.

The BR must not derive PRODUCT_STATUS directly from CATEGORY.

--------------------------------------------------------------------------------

Derivation Logic

DERIVED_PRODUCT_GROUP Values:

STORE_OPERATIONS

→ ACTIVE

------------------------------------------------------------

CONSUMER_PRODUCTS

→ ACTIVE

------------------------------------------------------------

HEALTH_BEAUTY

→ ACTIVE

------------------------------------------------------------

LIFESTYLE

→ ACTIVE

------------------------------------------------------------

BUSINESS_PRODUCTS

→ ACTIVE

------------------------------------------------------------

SPECIALTY

→ REVIEW

------------------------------------------------------------

OTHER

→ REVIEW

------------------------------------------------------------

Everything Else

→ REVIEW

--------------------------------------------------------------------------------

Phase 1 – Read Active Master Records

Read:

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

Filter:

ACTIVE_FLAG = 'Y'

Create a working dataset.

--------------------------------------------------------------------------------

Phase 2 – Derive Product Status

Apply the approved CASE statement.

Create:

NEW_DERIVED_PRODUCT_STATUS

for every active master record.

--------------------------------------------------------------------------------

Phase 3 – Identify Changed Records

Generate UPDATE actions only when:

COALESCE(DERIVED_PRODUCT_STATUS,'')
<>
COALESCE(NEW_DERIVED_PRODUCT_STATUS,'')

No action shall be generated when values are identical.

This prevents unnecessary version creation.

--------------------------------------------------------------------------------

Phase 3A – Duplicate Action Prevention

Before generating a new UPDATE action:

Verify that an equivalent pending UPDATE action does not already exist.

Equivalent means:

- same ENTITY_KEY
- same ACTION_TYPE
- same ACTION_SOURCE
- same DERIVED_PRODUCT_STATUS value
- ACTION_STATUS = 'PENDING'
- ACTIONED_FLAG = 'N'

If an equivalent pending action already exists:

Do not generate another UPDATE action.

The Business Rule must remain idempotent.

Repeated execution of the BR before DAL execution must not create duplicate pending actions.

Implementation pattern:

AND NOT EXISTS (
    SELECT 1
    FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG al
    WHERE al.ENTITY_KEY = d.ENTITY_KEY
      AND al.ACTION_TYPE = 'UPDATE'
      AND al.ACTION_SOURCE = 'P14_PRODUCT_STATUS'
      AND al.ACTION_STATUS = 'PENDING'
      AND al.ACTIONED_FLAG = 'N'
      AND al.DERIVED_PRODUCT_STATUS =
          d.NEW_DERIVED_PRODUCT_STATUS
)

--------------------------------------------------------------------------------

Phase 4 – Generate UPDATE Actions

Insert records into:

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

Populate only:

ENTITY_KEY

ACTION_TYPE = 'UPDATE'

ACTION_SOURCE = 'P14_PRODUCT_STATUS'

DERIVED_PRODUCT_STATUS =
NEW_DERIVED_PRODUCT_STATUS

ACTION_STATUS = 'PENDING'

ACTIONED_FLAG = 'N'

CREATED_DTTM = CURRENT_TIMESTAMP

--------------------------------------------------------------------------------

Action Payload Rule

Only the following business payload shall be populated:

ACTION_SOURCE = 'P14_PRODUCT_STATUS'

DERIVED_PRODUCT_STATUS

All other business attributes must remain NULL.

Examples:

BRAND = NULL
PRODUCT_NAME = NULL
CATEGORY = NULL
MANUFACTURER = NULL
SALE_PRICE = NULL
SIZE = NULL

ERP_PRODUCT_ID = NULL
SUPPLIER_PRODUCT_ID = NULL
INVENTORY_PRODUCT_ID = NULL
ECOMMERCE_PRODUCT_ID = NULL

DERIVED_PRODUCT_FAMILY = NULL
DERIVED_PRODUCT_GROUP = NULL

The DAL is responsible for preserving existing values using attribute-level merge logic.

--------------------------------------------------------------------------------

Phase 5 – Validation

Validate UPDATE actions generated.

Validation Query:

SELECT
    COUNT(*) AS UPDATE_ACTIONS_CREATED
FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
WHERE ACTION_TYPE = 'UPDATE'
  AND ACTION_SOURCE = 'P14_PRODUCT_STATUS'
  AND ACTION_STATUS = 'PENDING'
  AND ACTIONED_FLAG = 'N'
  AND DERIVED_PRODUCT_STATUS IS NOT NULL;

--------------------------------------------------------------------------------

Business Rule Guardrails

This BR must not:

- update INTM_PRODUCT_MASTER
- invoke DAL logic
- modify active master records
- generate CREATE actions
- generate DELETE actions
- derive PRODUCT_FAMILY
- derive PRODUCT_GROUP

The BR generates UPDATE actions only.

--------------------------------------------------------------------------------

Execution Flow

INTM_PRODUCT_MASTER
↓
Read DERIVED_PRODUCT_GROUP
↓
Derive Product Status
↓
ACTION_LOG (UPDATE)
↓
P11 DAL
↓
INTM_PRODUCT_MASTER Version N+1

--------------------------------------------------------------------------------

Success Criteria

Execution shall:

Read Active Masters
↓
Read DERIVED_PRODUCT_GROUP
↓
Derive Product Status
↓
Compare Existing vs New Value
↓
Prevent Duplicate Pending Actions
↓
Generate UPDATE Actions Only For Changes
↓
Insert Actions Into ACTION_LOG
↓
Await DAL Execution

No direct master updates are permitted.
