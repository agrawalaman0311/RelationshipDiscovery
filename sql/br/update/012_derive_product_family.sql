/*======================================================================
  012_DERIVE_PRODUCT_FAMILY.SQL
  Business Rule – Derive DERIVED_PRODUCT_FAMILY from CATEGORY
  and generate UPDATE actions into ACTION_LOG.

  This BR does not update INTM_PRODUCT_MASTER directly.
  This BR does not derive DERIVED_PRODUCT_GROUP or DERIVED_PRODUCT_STATUS.
======================================================================*/

----------------------------------------------------------------------
-- PHASE 1: Read Active Master Records
----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTERS AS
SELECT
    ENTITY_KEY,
    CATEGORY,
    DERIVED_PRODUCT_FAMILY
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ACTIVE_FLAG = 'Y';

----------------------------------------------------------------------
-- PHASE 2: Derive Product Family
----------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE RELATIONSHIP_DISCOVERY_DB.INTM.TMP_DERIVED_FAMILY AS
SELECT
    ENTITY_KEY,
    DERIVED_PRODUCT_FAMILY AS CURRENT_DERIVED_PRODUCT_FAMILY,
    CASE UPPER(TRIM(CATEGORY))
        WHEN 'CHEM-STORE'              THEN 'CHEMICALS'
        WHEN 'CLEANING SUPPLIES'       THEN 'CHEMICALS'
        WHEN 'CLEANING'                THEN 'CHEMICALS'
        WHEN 'CLEANING/CHEMICAL'       THEN 'CHEMICALS'
        WHEN 'FOOD-STORE'              THEN 'FOOD'
        WHEN 'FOOD & GROCERY'          THEN 'FOOD'
        WHEN 'FOOD/BEV'                THEN 'FOOD'
        WHEN 'FOOD & BEVERAGE'         THEN 'FOOD'
        WHEN 'PERS-STORE'              THEN 'PERSONAL_HEALTH'
        WHEN 'PERSONAL CARE'           THEN 'PERSONAL_HEALTH'
        WHEN 'PERSONAL/CARE'           THEN 'PERSONAL_HEALTH'
        WHEN 'BEAUTY & PERSONAL CARE'  THEN 'PERSONAL_HEALTH'
        WHEN 'HEALTH & WELLNESS'       THEN 'PERSONAL_HEALTH'
        WHEN 'HEALTHCARE'              THEN 'PERSONAL_HEALTH'
        WHEN 'HEALTHCARE/MEDICAL'      THEN 'PERSONAL_HEALTH'
        WHEN 'MED-STORE'               THEN 'PERSONAL_HEALTH'
        WHEN 'AUTO-STORE'              THEN 'AUTOMOTIVE'
        WHEN 'AUTO/PARTS'              THEN 'AUTOMOTIVE'
        WHEN 'AUTOMOTIVE'              THEN 'AUTOMOTIVE'
        WHEN 'AUTOMOTIVE PARTS'        THEN 'AUTOMOTIVE'
        WHEN 'HOME-STORE'              THEN 'HOME'
        WHEN 'HOME & GARDEN'           THEN 'HOME'
        WHEN 'HOME/GARDEN'             THEN 'HOME'
        WHEN 'OFF-STORE'               THEN 'OFFICE'
        WHEN 'OFFICE SUPPLIES'         THEN 'OFFICE'
        WHEN 'OFFICE & SCHOOL'         THEN 'OFFICE'
        WHEN 'OFFICE/BUSINESS'         THEN 'OFFICE'
        WHEN 'ELEC-STORE'              THEN 'ELECTRONICS'
        WHEN 'ELECTRONICS'             THEN 'ELECTRONICS'
        WHEN 'ELECTRONICS & GADGETS'   THEN 'ELECTRONICS'
        WHEN 'IND-STORE'               THEN 'INDUSTRIAL'
        WHEN 'INDUSTRIAL'              THEN 'INDUSTRIAL'
        WHEN 'INDUSTRIAL & SCIENTIFIC' THEN 'INDUSTRIAL'
        WHEN 'INDUSTRIAL/HEAVY'        THEN 'INDUSTRIAL'
        WHEN 'WAREHOUSE-ONLY'          THEN 'INDUSTRIAL'
        WHEN 'WHOLESALE/BULK'          THEN 'INDUSTRIAL'
        WHEN 'CONS-STORE'              THEN 'CONSUMER'
        WHEN 'CONSUMER GOODS'          THEN 'CONSUMER'
        WHEN 'CONSUMER PRODUCTS'       THEN 'CONSUMER'
        WHEN 'CONSUMER/FMCG'           THEN 'CONSUMER'
        WHEN 'MARKETPLACE EXCLUSIVES'  THEN 'SPECIALTY'
        WHEN 'SPECIALTY'               THEN 'SPECIALTY'
        ELSE 'OTHER'
    END AS NEW_DERIVED_PRODUCT_FAMILY
FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTERS;

----------------------------------------------------------------------
-- PHASE 3 & 3A & 4: Generate UPDATE Actions
-- Only where value changed AND no equivalent pending action exists
----------------------------------------------------------------------
INSERT INTO RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG (
    ACTION_TYPE,
    ACTION_SOURCE,
    ACTION_STATUS,
    ACTIONED_FLAG,
    ENTITY_KEY,
    DERIVED_PRODUCT_FAMILY,
    CREATED_DTTM
)
SELECT
    'UPDATE',
    'P12_PRODUCT_FAMILY',
    'PENDING',
    'N',
    d.ENTITY_KEY,
    d.NEW_DERIVED_PRODUCT_FAMILY,
    CURRENT_TIMESTAMP()
FROM RELATIONSHIP_DISCOVERY_DB.INTM.TMP_DERIVED_FAMILY d
WHERE COALESCE(d.CURRENT_DERIVED_PRODUCT_FAMILY, '')
   <> COALESCE(d.NEW_DERIVED_PRODUCT_FAMILY, '')
  AND NOT EXISTS (
      SELECT 1
      FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG al
      WHERE al.ENTITY_KEY = d.ENTITY_KEY
        AND al.ACTION_TYPE = 'UPDATE'
        AND al.ACTION_SOURCE = 'P12_PRODUCT_FAMILY'
        AND al.ACTION_STATUS = 'PENDING'
        AND al.ACTIONED_FLAG = 'N'
        AND al.DERIVED_PRODUCT_FAMILY = d.NEW_DERIVED_PRODUCT_FAMILY
  );

----------------------------------------------------------------------
-- PHASE 5: Validation
----------------------------------------------------------------------
SELECT COUNT(*) AS UPDATE_ACTIONS_CREATED
FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
WHERE ACTION_TYPE = 'UPDATE'
  AND ACTION_SOURCE = 'P12_PRODUCT_FAMILY'
  AND ACTION_STATUS = 'PENDING'
  AND ACTIONED_FLAG = 'N'
  AND DERIVED_PRODUCT_FAMILY IS NOT NULL;

----------------------------------------------------------------------
-- Cleanup
----------------------------------------------------------------------
DROP TABLE IF EXISTS RELATIONSHIP_DISCOVERY_DB.INTM.TMP_ACTIVE_MASTERS;
DROP TABLE IF EXISTS RELATIONSHIP_DISCOVERY_DB.INTM.TMP_DERIVED_FAMILY;
