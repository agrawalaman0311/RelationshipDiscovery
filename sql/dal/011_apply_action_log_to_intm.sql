/*======================================================================
  011_APPLY_ACTION_LOG_TO_PRODUCT_MASTER.SQL
  Data Access Layer (DAL) – Apply pending ACTION_LOG actions to
  INTM_PRODUCT_MASTER.

  Execution-only layer. No business logic, no entity resolution,
  no survivorship, no deduplication, no matching.
======================================================================*/

----------------------------------------------------------------------
-- PRE-REQUISITE: Ensure required columns exist
----------------------------------------------------------------------
ALTER TABLE RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
  ADD COLUMN IF NOT EXISTS ACTIONED_DTTM TIMESTAMP_NTZ;

ALTER TABLE RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
  ADD COLUMN IF NOT EXISTS SOURCE_EXECUTION_REFERENCE VARCHAR(255);

----------------------------------------------------------------------
-- PHASE 1: Load Pending Actions
----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE RELATIONSHIP_DISCOVERY_DB.INTM.TMP_PENDING_ACTIONS AS
SELECT *
FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
WHERE ACTION_STATUS = 'PENDING'
  AND ACTIONED_FLAG = 'N'
  AND ACTION_TYPE IN ('CREATE', 'UPDATE', 'DELETE');

----------------------------------------------------------------------
-- PHASE 2: Capture Current Active Master Snapshot
----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTER_SNAPSHOT AS
SELECT *
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ACTIVE_FLAG = 'Y';

----------------------------------------------------------------------
-- PHASE 3: CREATE Processing
----------------------------------------------------------------------
INSERT INTO RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER (
    ENTITY_KEY,
    BRAND,
    PRODUCT_NAME,
    CATEGORY,
    MANUFACTURER,
    SALE_PRICE,
    SIZE,
    ERP_PRODUCT_ID,
    SUPPLIER_PRODUCT_ID,
    INVENTORY_PRODUCT_ID,
    ECOMMERCE_PRODUCT_ID,
    DERIVED_PRODUCT_FAMILY,
    DERIVED_PRODUCT_GROUP,
    DERIVED_PRODUCT_STATUS,
    SOURCE_EXECUTION_REFERENCE,
    VERSION_NO,
    ACTIVE_FLAG,
    CREATED_DTTM,
    UPDATED_DTTM
)
SELECT
    a.ENTITY_KEY,
    a.BRAND,
    a.PRODUCT_NAME,
    a.CATEGORY,
    a.MANUFACTURER,
    a.SALE_PRICE,
    a.SIZE,
    a.ERP_PRODUCT_ID,
    a.SUPPLIER_PRODUCT_ID,
    a.INVENTORY_PRODUCT_ID,
    a.ECOMMERCE_PRODUCT_ID,
    a.DERIVED_PRODUCT_FAMILY,
    a.DERIVED_PRODUCT_GROUP,
    a.DERIVED_PRODUCT_STATUS,
    a.SOURCE_EXECUTION_REFERENCE,
    1,
    'Y',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_PENDING_ACTIONS a
WHERE a.ACTION_TYPE = 'CREATE'
  AND NOT EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTER_SNAPSHOT s
      WHERE s.ENTITY_KEY = a.ENTITY_KEY
  );

----------------------------------------------------------------------
-- PHASE 4: UPDATE Processing – Deactivate current active versions
----------------------------------------------------------------------
UPDATE RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER m
SET m.ACTIVE_FLAG = 'N',
    m.UPDATED_DTTM = CURRENT_TIMESTAMP()
WHERE m.ACTIVE_FLAG = 'Y'
  AND EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_PENDING_ACTIONS a
      WHERE a.ACTION_TYPE = 'UPDATE'
        AND a.ENTITY_KEY = m.ENTITY_KEY
  );

----------------------------------------------------------------------
-- PHASE 4 (cont.): INSERT new version with merged attributes
-- VERSION_NO sourced from snapshot (before deactivation)
-- NULL in ACTION_LOG = "not supplied" → preserve existing value
----------------------------------------------------------------------
INSERT INTO RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER (
    ENTITY_KEY,
    BRAND,
    PRODUCT_NAME,
    CATEGORY,
    MANUFACTURER,
    SALE_PRICE,
    SIZE,
    ERP_PRODUCT_ID,
    SUPPLIER_PRODUCT_ID,
    INVENTORY_PRODUCT_ID,
    ECOMMERCE_PRODUCT_ID,
    DERIVED_PRODUCT_FAMILY,
    DERIVED_PRODUCT_GROUP,
    DERIVED_PRODUCT_STATUS,
    SOURCE_EXECUTION_REFERENCE,
    VERSION_NO,
    ACTIVE_FLAG,
    CREATED_DTTM,
    UPDATED_DTTM
)
SELECT
    a.ENTITY_KEY,
    COALESCE(a.BRAND,                      s.BRAND),
    COALESCE(a.PRODUCT_NAME,               s.PRODUCT_NAME),
    COALESCE(a.CATEGORY,                   s.CATEGORY),
    COALESCE(a.MANUFACTURER,               s.MANUFACTURER),
    COALESCE(a.SALE_PRICE,                 s.SALE_PRICE),
    COALESCE(a.SIZE,                       s.SIZE),
    COALESCE(a.ERP_PRODUCT_ID,             s.ERP_PRODUCT_ID),
    COALESCE(a.SUPPLIER_PRODUCT_ID,        s.SUPPLIER_PRODUCT_ID),
    COALESCE(a.INVENTORY_PRODUCT_ID,       s.INVENTORY_PRODUCT_ID),
    COALESCE(a.ECOMMERCE_PRODUCT_ID,       s.ECOMMERCE_PRODUCT_ID),
    COALESCE(a.DERIVED_PRODUCT_FAMILY,     s.DERIVED_PRODUCT_FAMILY),
    COALESCE(a.DERIVED_PRODUCT_GROUP,      s.DERIVED_PRODUCT_GROUP),
    COALESCE(a.DERIVED_PRODUCT_STATUS,     s.DERIVED_PRODUCT_STATUS),
    COALESCE(a.SOURCE_EXECUTION_REFERENCE, s.SOURCE_EXECUTION_REFERENCE),
    s.VERSION_NO + 1,
    'Y',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_PENDING_ACTIONS a
INNER JOIN RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTER_SNAPSHOT s
    ON s.ENTITY_KEY = a.ENTITY_KEY
WHERE a.ACTION_TYPE = 'UPDATE';

----------------------------------------------------------------------
-- PHASE 5: DELETE Processing – Soft delete (deactivate)
----------------------------------------------------------------------
UPDATE RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER m
SET m.ACTIVE_FLAG = 'N',
    m.UPDATED_DTTM = CURRENT_TIMESTAMP()
WHERE m.ACTIVE_FLAG = 'Y'
  AND EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_PENDING_ACTIONS a
      WHERE a.ACTION_TYPE = 'DELETE'
        AND a.ENTITY_KEY = m.ENTITY_KEY
  );

----------------------------------------------------------------------
-- PHASE 6: Action Completion – Validate state then mark COMPLETED
----------------------------------------------------------------------

-- CREATE success: active master record now exists for ENTITY_KEY
UPDATE RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG al
SET al.ACTION_STATUS  = 'COMPLETED',
    al.ACTIONED_FLAG  = 'Y',
    al.ACTIONED_DTTM  = CURRENT_TIMESTAMP()
WHERE al.ACTION_STATUS = 'PENDING'
  AND al.ACTIONED_FLAG = 'N'
  AND al.ACTION_TYPE = 'CREATE'
  AND EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER m
      WHERE m.ENTITY_KEY = al.ENTITY_KEY
        AND m.ACTIVE_FLAG = 'Y'
  );

-- UPDATE success: new active version exists with VERSION_NO = snapshot + 1
UPDATE RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG al
SET al.ACTION_STATUS  = 'COMPLETED',
    al.ACTIONED_FLAG  = 'Y',
    al.ACTIONED_DTTM  = CURRENT_TIMESTAMP()
WHERE al.ACTION_STATUS = 'PENDING'
  AND al.ACTIONED_FLAG = 'N'
  AND al.ACTION_TYPE = 'UPDATE'
  AND EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER m
      INNER JOIN RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTER_SNAPSHOT s
          ON s.ENTITY_KEY = m.ENTITY_KEY
      WHERE m.ENTITY_KEY = al.ENTITY_KEY
        AND m.ACTIVE_FLAG = 'Y'
        AND m.VERSION_NO = s.VERSION_NO + 1
  );

-- DELETE success: no active version exists for ENTITY_KEY
UPDATE RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG al
SET al.ACTION_STATUS  = 'COMPLETED',
    al.ACTIONED_FLAG  = 'Y',
    al.ACTIONED_DTTM  = CURRENT_TIMESTAMP()
WHERE al.ACTION_STATUS = 'PENDING'
  AND al.ACTIONED_FLAG = 'N'
  AND al.ACTION_TYPE = 'DELETE'
  AND NOT EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER m
      WHERE m.ENTITY_KEY = al.ENTITY_KEY
        AND m.ACTIVE_FLAG = 'Y'
  );

----------------------------------------------------------------------
-- PHASE 7: Mark SKIPPED CREATEs (ENTITY_KEY already had active master)
-- SKIPPED is considered processed – ACTIONED_FLAG = 'Y'
----------------------------------------------------------------------
UPDATE RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG al
SET al.ACTION_STATUS  = 'SKIPPED',
    al.ACTIONED_FLAG  = 'Y',
    al.ACTIONED_DTTM  = CURRENT_TIMESTAMP()
WHERE al.ACTION_STATUS = 'PENDING'
  AND al.ACTIONED_FLAG = 'N'
  AND al.ACTION_TYPE = 'CREATE'
  AND EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTER_SNAPSHOT s
      WHERE s.ENTITY_KEY = al.ENTITY_KEY
  );

----------------------------------------------------------------------
-- PHASE 8: Mark remaining unprocessed actions as FAILED
----------------------------------------------------------------------
UPDATE RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG al
SET al.ACTION_STATUS = 'FAILED'
WHERE al.ACTION_STATUS = 'PENDING'
  AND al.ACTIONED_FLAG = 'N'
  AND al.ACTION_TYPE IN ('CREATE', 'UPDATE', 'DELETE')
  AND al.EXECUTION_ID IN (
      SELECT EXECUTION_ID
      FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_PENDING_ACTIONS
  );

----------------------------------------------------------------------
-- PHASE 10: Version Integrity Validation
----------------------------------------------------------------------
SELECT ENTITY_KEY, COUNT(*) AS ACTIVE_COUNT
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ACTIVE_FLAG = 'Y'
GROUP BY ENTITY_KEY
HAVING COUNT(*) > 1;

----------------------------------------------------------------------
-- PHASE 11: Action Integrity Validation
----------------------------------------------------------------------
SELECT COUNT(*) AS REMAINING_PENDING
FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
WHERE ACTION_STATUS = 'PENDING'
  AND ACTIONED_FLAG = 'N';

----------------------------------------------------------------------
-- Cleanup
----------------------------------------------------------------------
DROP TABLE IF EXISTS RELATIONSHIP_DISCOVERY_DB.INTM.TMP_PENDING_ACTIONS;
DROP TABLE IF EXISTS RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTER_SNAPSHOT;
