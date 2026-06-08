/*======================================================================
  014_DERIVE_PRODUCT_STATUS.SQL
  Business Rule – Derive DERIVED_PRODUCT_STATUS from DERIVED_PRODUCT_GROUP
  and generate UPDATE actions into ACTION_LOG.

  This BR does not update INTM_PRODUCT_MASTER directly.
  This BR does not derive DERIVED_PRODUCT_FAMILY or DERIVED_PRODUCT_GROUP.
======================================================================*/

----------------------------------------------------------------------
-- PHASE 1: Read Active Master Records
----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTERS_STS AS
SELECT
    ENTITY_KEY,
    DERIVED_PRODUCT_GROUP,
    DERIVED_PRODUCT_STATUS
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ACTIVE_FLAG = 'Y';

----------------------------------------------------------------------
-- PHASE 2: Derive Product Status from DERIVED_PRODUCT_GROUP
----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE RELATIONSHIP_DISCOVERY_DB.INTM.TMP_DERIVED_STATUS AS
SELECT
    ENTITY_KEY,
    DERIVED_PRODUCT_STATUS AS CURRENT_DERIVED_PRODUCT_STATUS,
    CASE DERIVED_PRODUCT_GROUP
        WHEN 'STORE_OPERATIONS'   THEN 'ACTIVE'
        WHEN 'CONSUMER_PRODUCTS'  THEN 'ACTIVE'
        WHEN 'HEALTH_BEAUTY'      THEN 'ACTIVE'
        WHEN 'LIFESTYLE'          THEN 'ACTIVE'
        WHEN 'BUSINESS_PRODUCTS'  THEN 'ACTIVE'
        WHEN 'SPECIALTY'          THEN 'REVIEW'
        WHEN 'OTHER'              THEN 'REVIEW'
        ELSE 'REVIEW'
    END AS NEW_DERIVED_PRODUCT_STATUS
FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTERS_STS;

----------------------------------------------------------------------
-- PHASE 3, 3A & 4: Generate UPDATE Actions
-- Only where value changed AND no equivalent pending action exists
----------------------------------------------------------------------
INSERT INTO RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG (
    ACTION_TYPE,
    ACTION_SOURCE,
    ACTION_STATUS,
    ACTIONED_FLAG,
    ENTITY_KEY,
    DERIVED_PRODUCT_STATUS,
    CREATED_DTTM
)
SELECT
    'UPDATE',
    'P14_PRODUCT_STATUS',
    'PENDING',
    'N',
    d.ENTITY_KEY,
    d.NEW_DERIVED_PRODUCT_STATUS,
    CURRENT_TIMESTAMP()
FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_DERIVED_STATUS d
WHERE COALESCE(d.CURRENT_DERIVED_PRODUCT_STATUS, '')
   <> COALESCE(d.NEW_DERIVED_PRODUCT_STATUS, '')
  AND NOT EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG al
      WHERE al.ENTITY_KEY = d.ENTITY_KEY
        AND al.ACTION_TYPE = 'UPDATE'
        AND al.ACTION_SOURCE = 'P14_PRODUCT_STATUS'
        AND al.ACTION_STATUS = 'PENDING'
        AND al.ACTIONED_FLAG = 'N'
        AND al.DERIVED_PRODUCT_STATUS = d.NEW_DERIVED_PRODUCT_STATUS
  );

----------------------------------------------------------------------
-- PHASE 5: Validation
----------------------------------------------------------------------
SELECT COUNT(*) AS UPDATE_ACTIONS_CREATED
FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
WHERE ACTION_TYPE = 'UPDATE'
  AND ACTION_SOURCE = 'P14_PRODUCT_STATUS'
  AND ACTION_STATUS = 'PENDING'
  AND ACTIONED_FLAG = 'N'
  AND DERIVED_PRODUCT_STATUS IS NOT NULL;

----------------------------------------------------------------------
-- Cleanup
----------------------------------------------------------------------
DROP TABLE IF EXISTS RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTERS_STS;
DROP TABLE IF EXISTS RELATIONSHIP_DISCOVERY_DB.INTM.TMP_DERIVED_STATUS;
