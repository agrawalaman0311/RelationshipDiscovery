PROMPT 011 – APPLY ACTION LOG TO PRODUCT MASTER

Objective

Generate executable Snowflake SQL that applies pending actions from ACTION_LOG to INTM_PRODUCT_MASTER.

This prompt implements the Data Access Layer (DAL).

The DAL is an execution layer only.

The DAL shall not perform:

- survivorship
- entity resolution
- deduplication
- relationship discovery
- DQ scoring
- ENTITY_KEY generation
- business rule evaluation
- matching
- consolidation

All business decisions have already been completed by upstream Business Rules.

The DAL is responsible only for applying approved actions to the Product Master.

--------------------------------------------------------------------------------

Output

Generate SQL for:

sql/dal/011_apply_action_log_to_product_master.sql

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

Source Tables

Action Source

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

Master Target

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

--------------------------------------------------------------------------------

Business Context

ACTION_LOG represents system intent.

INTM_PRODUCT_MASTER represents system state.

Business Rules determine:

- CREATE
- UPDATE
- DELETE

The DAL executes those decisions.

The DAL must never determine action types.

The DAL must never override action types.

The DAL must never generate new actions.

--------------------------------------------------------------------------------

Supported Actions

The DAL shall process:

- CREATE
- UPDATE
- DELETE

Ignore all other action types.

--------------------------------------------------------------------------------

Processing Scope

Only process actions where:

ACTION_STATUS = 'PENDING'
AND ACTIONED_FLAG = 'N'

Already processed actions must never be reprocessed.

This guarantees idempotent execution.

--------------------------------------------------------------------------------

Master Table Requirements

INTM_PRODUCT_MASTER shall support:

- ENTITY_KEY
- VERSION_NO
- ACTIVE_FLAG
- CREATED_DTTM
- UPDATED_DTTM

Version history must be retained.

Physical deletion is prohibited.

--------------------------------------------------------------------------------

Master Versioning Principles

INTM_PRODUCT_MASTER stores complete state.

ACTION_LOG stores intended changes.

ACTION_LOG is not required to contain a complete record.

UPDATE actions may contain only changed attributes.

The DAL is responsible for constructing a complete replacement version.

--------------------------------------------------------------------------------

Phase 1 – Load Pending Actions

Read all pending actions from:

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

Filter:

ACTION_STATUS = 'PENDING'
AND ACTIONED_FLAG = 'N'
AND ACTION_TYPE IN ('CREATE','UPDATE','DELETE')

Create a working action dataset.

--------------------------------------------------------------------------------

Phase 2 – Capture Current Active Master Snapshot

Before any UPDATE or DELETE processing:

Create a snapshot dataset containing all currently active master records.

Filter:

ACTIVE_FLAG = 'Y'

This snapshot becomes the authoritative source for:

- UPDATE merge processing
- DELETE processing
- VERSION_NO calculations
- completion validation

The snapshot must be created before any records are deactivated.

The DAL must never calculate new versions from already updated records.

--------------------------------------------------------------------------------

Phase 3 – CREATE Processing

Process:

ACTION_TYPE = 'CREATE'

For each CREATE action:

Verify that no active master already exists.

Condition:

NOT EXISTS (
    SELECT 1
    FROM INTM_PRODUCT_MASTER
    WHERE ENTITY_KEY = ACTION_LOG.ENTITY_KEY
      AND ACTIVE_FLAG = 'Y'
)

If no active master exists:

Insert new master record.

Populate:

- ENTITY_KEY

- BRAND
- PRODUCT_NAME
- CATEGORY
- MANUFACTURER
- SALE_PRICE
- SIZE

- ERP_PRODUCT_ID
- SUPPLIER_PRODUCT_ID
- INVENTORY_PRODUCT_ID
- ECOMMERCE_PRODUCT_ID

- DERIVED_PRODUCT_FAMILY
- DERIVED_PRODUCT_GROUP
- DERIVED_PRODUCT_STATUS

- SOURCE_EXECUTION_REFERENCE

Set:

VERSION_NO = 1

ACTIVE_FLAG = 'Y'

CREATED_DTTM = CURRENT_TIMESTAMP

UPDATED_DTTM = CURRENT_TIMESTAMP

Only successfully inserted CREATE actions may later be marked COMPLETED.

--------------------------------------------------------------------------------

Phase 4 – UPDATE Processing

Process:

ACTION_TYPE = 'UPDATE'

Locate the current active master version using the snapshot captured in Phase 2.

--------------------------------------------------------------------------------

Update Action Philosophy

ACTION_LOG contains deltas.

INTM_PRODUCT_MASTER contains complete state.

DAL merges delta plus active master to create a complete replacement version.

Existing values must be retained unless explicitly updated.

This behaviour is mandatory.

--------------------------------------------------------------------------------

Attribute Merge Rule

For every attribute:

NEW_VALUE =
COALESCE(
    ACTION_LOG.VALUE,
    CURRENT_ACTIVE_MASTER.VALUE
)

Apply this pattern to:

- BRAND
- PRODUCT_NAME
- CATEGORY
- MANUFACTURER
- SALE_PRICE
- SIZE

- ERP_PRODUCT_ID
- SUPPLIER_PRODUCT_ID
- INVENTORY_PRODUCT_ID
- ECOMMERCE_PRODUCT_ID

- DERIVED_PRODUCT_FAMILY
- DERIVED_PRODUCT_GROUP
- DERIVED_PRODUCT_STATUS

- SOURCE_EXECUTION_REFERENCE

--------------------------------------------------------------------------------

Master State Preservation Rule

A NULL value in ACTION_LOG does not mean:

"overwrite existing value with NULL"

A NULL value in ACTION_LOG means:

"attribute not supplied"

The DAL shall preserve the existing master value.

Only explicitly populated values may replace existing values.

--------------------------------------------------------------------------------

Versioning Rule

Deactivate current active version.

Update:

ACTIVE_FLAG = 'N'

UPDATED_DTTM = CURRENT_TIMESTAMP

Insert replacement version.

Set:

VERSION_NO =
CURRENT_ACTIVE_MASTER.VERSION_NO + 1

ACTIVE_FLAG = 'Y'

CREATED_DTTM = CURRENT_TIMESTAMP

UPDATED_DTTM = CURRENT_TIMESTAMP

The replacement record becomes the new active version.

VERSION_NO must be sourced from the snapshot.

Do not derive VERSION_NO from already updated records.

--------------------------------------------------------------------------------

Phase 5 – DELETE Processing

Process:

ACTION_TYPE = 'DELETE'

Locate active master using the snapshot captured in Phase 2.

Deactivate record.

Update:

ACTIVE_FLAG = 'N'

UPDATED_DTTM = CURRENT_TIMESTAMP

Do not physically delete.

Do not remove historical versions.

Do not create a replacement version.

DELETE actions do not generate new versions.

The latest version simply becomes inactive.

--------------------------------------------------------------------------------

Phase 6 – Successful Execution Validation

An action may only be marked COMPLETED if the intended DAL operation was successfully applied.

The DAL must distinguish between:

- action identified
- action attempted
- action successfully applied

Only successfully applied actions may be marked COMPLETED.

--------------------------------------------------------------------------------

CREATE Success Validation

Before marking a CREATE action as COMPLETED:

Verify that an active master record now exists for ENTITY_KEY.

Example:

EXISTS (
    SELECT 1
    FROM INTM_PRODUCT_MASTER
    WHERE ENTITY_KEY = ACTION_LOG.ENTITY_KEY
      AND ACTIVE_FLAG = 'Y'
)

Only then:

ACTION_STATUS = 'COMPLETED'

ACTIONED_FLAG = 'Y'

ACTIONED_DTTM = CURRENT_TIMESTAMP

--------------------------------------------------------------------------------

UPDATE Success Validation

Before marking an UPDATE action as COMPLETED:

Verify that:

- a new active version exists
- VERSION_NO increased by 1
- exactly one active version exists

Validation must use the Phase 2 snapshot.

Do not mark UPDATE actions completed solely because an ENTITY_KEY existed in the snapshot.

The DAL must validate successful version creation.

Only then:

ACTION_STATUS = 'COMPLETED'

ACTIONED_FLAG = 'Y'

ACTIONED_DTTM = CURRENT_TIMESTAMP

--------------------------------------------------------------------------------

DELETE Success Validation

Before marking a DELETE action as COMPLETED:

Verify that:

No active version exists for ENTITY_KEY.

Example:

NOT EXISTS (
    SELECT 1
    FROM INTM_PRODUCT_MASTER
    WHERE ENTITY_KEY = ACTION_LOG.ENTITY_KEY
      AND ACTIVE_FLAG = 'Y'
)

Only then:

ACTION_STATUS = 'COMPLETED'

ACTIONED_FLAG = 'Y'

ACTIONED_DTTM = CURRENT_TIMESTAMP

--------------------------------------------------------------------------------

Phase 7 – Skipped Actions

If a CREATE action is received for an ENTITY_KEY that already has an active master record:

Do not insert a duplicate master.

Mark:

ACTION_STATUS = 'SKIPPED'

ACTIONED_FLAG = 'Y'

ACTIONED_DTTM = CURRENT_TIMESTAMP

A SKIPPED action is considered processed.

A SKIPPED action must never remain eligible for reprocessing.

--------------------------------------------------------------------------------

Phase 8 – Failure Handling

If processing fails:

ACTION_STATUS = 'FAILED'

ACTIONED_FLAG = 'N'

Do not populate ACTIONED_DTTM.

FAILED actions remain available for controlled retry.

--------------------------------------------------------------------------------

Phase 9 – Idempotency Protection

The DAL must be safely rerunnable.

Only actions satisfying:

ACTION_STATUS = 'PENDING'
AND ACTIONED_FLAG = 'N'

may be processed.

COMPLETED actions must never execute twice.

SKIPPED actions must never execute twice.

--------------------------------------------------------------------------------

Phase 10 – Version Integrity Validation

The generated SQL must guarantee:

Only one active version exists per ENTITY_KEY.

Validation:

SELECT
    ENTITY_KEY
FROM INTM_PRODUCT_MASTER
WHERE ACTIVE_FLAG = 'Y'
GROUP BY ENTITY_KEY
HAVING COUNT(*) > 1;

Expected result:

0 rows

--------------------------------------------------------------------------------

Phase 11 – Action Integrity Validation

Validation:

SELECT COUNT(*)
FROM ACTION_LOG
WHERE ACTION_STATUS = 'PENDING'
AND ACTIONED_FLAG = 'N';

Expected result:

0

excluding intentional failures awaiting retry.
--------------------------------------------------------------------------------

DAL Assumptions

The DAL assumes upstream Business Rules have already enforced:

- one actionable decision per ENTITY_KEY per execution cycle
- no conflicting CREATE, UPDATE or DELETE actions for the same ENTITY_KEY within a batch
- ACTION_LOG represents the final approved intent for execution

The DAL is not responsible for:

- resolving conflicting actions
- action prioritisation
- business decision arbitration

Conflicting actions represent upstream Business Rule defects.

The DAL executes approved actions exactly as provided.

  
--------------------------------------------------------------------------------

Phase 12 – DAL Guardrails

The DAL must not perform:

- Entity Resolution
- Relationship Discovery
- Graph Traversal
- Connected Components
- Business Rule Evaluation
- Survivorship
- DQ Scoring
- Entity Key Generation
- Master Deduplication
- Action Generation
- Matching Logic

The DAL is an execution layer only.

--------------------------------------------------------------------------------

Constraints

Do not generate:

- Business Rules
- Master Candidate Logic
- Relationship Logic
- Derived Attribute Logic
- Stewardship Logic
- Matching Logic

The DAL consumes decisions.

The DAL does not create decisions.

--------------------------------------------------------------------------------

Success Criteria

Execution shall:

Read Pending Actions
        ↓
Capture Active Master Snapshot
        ↓
Apply CREATE
Apply UPDATE
Apply DELETE
        ↓
Maintain Version History
        ↓
Retain Existing Values Unless Explicitly Updated
        ↓
Validate State Change
        ↓
Update Action Status
        ↓
Preserve One Active Version Per ENTITY_KEY
        ↓
Support Safe Re-Runs

Future Business Rules may generate additional CREATE, UPDATE or DELETE actions, which shall be processed by this same DAL implementation without modification.
