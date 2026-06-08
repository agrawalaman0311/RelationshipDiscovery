/*======================================================================
  015_PUBLISH_FINAL_PRODUCT_MASTER.SQL
  Business Utility – Publish active mastered records to FINAL layer.

  No business logic. No derivations. No actions. Publish-only.
======================================================================*/

----------------------------------------------------------------------
-- PHASE 2: Publish Final Product Master
----------------------------------------------------------------------
CREATE OR REPLACE TABLE RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER AS
SELECT
    ENTITY_KEY,
    ERP_PRODUCT_ID,
    SUPPLIER_PRODUCT_ID,
    INVENTORY_PRODUCT_ID,
    ECOMMERCE_PRODUCT_ID,
    BRAND,
    PRODUCT_NAME,
    CATEGORY,
    MANUFACTURER,
    SALE_PRICE,
    SIZE,
    DERIVED_PRODUCT_FAMILY,
    DERIVED_PRODUCT_GROUP,
    DERIVED_PRODUCT_STATUS,
    SOURCE_EXECUTION_REFERENCE,
    ACTION_SOURCE,
    VERSION_NO,
    CREATED_DTTM,
    UPDATED_DTTM
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ACTIVE_FLAG = 'Y';

----------------------------------------------------------------------
-- PHASE 3: Validation
----------------------------------------------------------------------
SELECT COUNT(*) AS FINAL_RECORD_COUNT
FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER;

SELECT COUNT(*) AS ACTIVE_MASTER_COUNT
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ACTIVE_FLAG = 'Y';
