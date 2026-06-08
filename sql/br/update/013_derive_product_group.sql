/*======================================================================
  013_DERIVE_PRODUCT_GROUP.SQL
  Business Rule – Derive DERIVED_PRODUCT_GROUP from DERIVED_PRODUCT_FAMILY
  and generate UPDATE actions into ACTION_LOG.

  This BR does not update INTM_PRODUCT_MASTER directly.
  This BR does not derive DERIVED_PRODUCT_FAMILY or DERIVED_PRODUCT_STATUS.
======================================================================*/

----------------------------------------------------------------------
-- PHASE 1: Read Active Master Records
----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTERS_GRP AS
SELECT
    ENTITY_KEY,
    DERIVED_PRODUCT_FAMILY,
    DERIVED_PRODUCT_GROUP
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ACTIVE_FLAG = 'Y';

----------------------------------------------------------------------
-- PHASE 2: Derive Product Group from DERIVED_PRODUCT_FAMILY
----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE RELATIONSHIP_DISCOVERY_DB.INTM.TMP_DERIVED_GROUP AS
SELECT
    ENTITY_KEY,
    DERIVED_PRODUCT_GROUP AS CURRENT_DERIVED_PRODUCT_GROUP,
    CASE DERIVED_PRODUCT_FAMILY
        WHEN 'CHEMICALS'        THEN 'STORE_OPERATIONS'
        WHEN 'INDUSTRIAL'       THEN 'STORE_OPERATIONS'
        WHEN 'FOOD'             THEN 'CONSUMER_PRODUCTS'
        WHEN 'CONSUMER'         THEN 'CONSUMER_PRODUCTS'
        WHEN 'PERSONAL_HEALTH'  THEN 'HEALTH_BEAUTY'
        WHEN 'HOME'             THEN 'LIFESTYLE'
        WHEN 'AUTOMOTIVE'       THEN 'LIFESTYLE'
        WHEN 'ELECTRONICS'      THEN 'LIFESTYLE'
        WHEN 'OFFICE'           THEN 'BUSINESS_PRODUCTS'
        WHEN 'SPECIALTY'        THEN 'SPECIALTY'
        WHEN 'OTHER'            THEN 'OTHER'
        ELSE 'OTHER'
    END AS NEW_DERIVED_PRODUCT_GROUP
FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTERS_GRP;

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
    DERIVED_PRODUCT_GROUP,
    CREATED_DTTM
)
SELECT
    'UPDATE',
    'P13_PRODUCT_GROUP',
    'PENDING',
    'N',
    d.ENTITY_KEY,
    d.NEW_DERIVED_PRODUCT_GROUP,
    CURRENT_TIMESTAMP()
FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_DERIVED_GROUP d
WHERE COALESCE(d.CURRENT_DERIVED_PRODUCT_GROUP, '')
   <> COALESCE(d.NEW_DERIVED_PRODUCT_GROUP, '')
  AND NOT EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG al
      WHERE al.ENTITY_KEY = d.ENTITY_KEY
        AND al.ACTION_TYPE = 'UPDATE'
        AND al.ACTION_SOURCE = 'P13_PRODUCT_GROUP'
        AND al.ACTION_STATUS = 'PENDING'
        AND al.ACTIONED_FLAG = 'N'
        AND al.DERIVED_PRODUCT_GROUP = d.NEW_DERIVED_PRODUCT_GROUP
  );

----------------------------------------------------------------------
-- PHASE 5: Validation
----------------------------------------------------------------------
SELECT COUNT(*) AS UPDATE_ACTIONS_CREATED
FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
WHERE ACTION_TYPE = 'UPDATE'
  AND ACTION_SOURCE = 'P13_PRODUCT_GROUP'
  AND ACTION_STATUS = 'PENDING'
  AND ACTIONED_FLAG = 'N'
  AND DERIVED_PRODUCT_GROUP IS NOT NULL;

----------------------------------------------------------------------
-- Cleanup
----------------------------------------------------------------------
DROP TABLE IF EXISTS RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTERS_GRP;
DROP TABLE IF EXISTS RELATIONSHIP_DISCOVERY_DB.INTM.TMP_DERIVED_GROUP;
