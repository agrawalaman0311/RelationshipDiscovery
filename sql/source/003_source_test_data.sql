CREATE OR REPLACE TABLE RELATIONSHIP_DISCOVERY_DB.SRC.PRODUCT_SEED AS
WITH
BRAND_LIST AS (
    SELECT ARRAY_CONSTRUCT(
        'Acme', 'Nexus', 'Pinnacle', 'Vertex', 'Horizon',
        'Summit', 'Atlas', 'Titan', 'Nova', 'Apex',
        'Procter & Gamble', 'Johnson & Johnson', 'Unilever', 'Colgate', 'Henkel',
        'Kimberly Clark', 'Reckitt', 'Church & Dwight', 'Spectrum', 'Clorox',
        'Vanguard', 'Meridian', 'Eclipse', 'Fusion', 'Catalyst',
        'Quantum', 'Sterling', 'Pioneer', 'Zenith', 'Cobalt'
    ) AS B
),
PRODUCT_LIST AS (
    SELECT ARRAY_CONSTRUCT(
        'Widget', 'Gadget', 'Module', 'Component', 'Assembly',
        'Sensor', 'Controller', 'Processor', 'Adapter', 'Connector',
        'Filter', 'Pump', 'Valve', 'Switch', 'Panel',
        'Motor', 'Drive', 'Relay', 'Bracket', 'Housing',
        'Cleaner', 'Detergent', 'Sanitizer', 'Polish', 'Sealer',
        'Lubricant', 'Adhesive', 'Coating', 'Primer', 'Solvent'
    ) AS P
),
CATEGORY_LIST AS (
    SELECT ARRAY_CONSTRUCT(
        'Electronics', 'Industrial', 'Consumer Goods', 'Healthcare', 'Automotive',
        'Home & Garden', 'Office Supplies', 'Food & Beverage', 'Personal Care', 'Cleaning'
    ) AS C
),
MANUFACTURER_LIST AS (
    SELECT ARRAY_CONSTRUCT(
        'Global Manufacturing Co', 'Pacific Industries', 'Continental Corp', 'National Products Inc', 'Premier Manufacturing',
        'Allied Industries', 'Standard Corp', 'Universal Manufacturing', 'Delta Industries', 'Omega Corp',
        'Eastern Manufacturing', 'Western Industries', 'Northern Corp', 'Southern Products', 'Central Manufacturing'
    ) AS M
),
SIZE_LIST AS (
    SELECT ARRAY_CONSTRUCT(
        '100ML', '250ML', '500ML', '1L', '2L',
        'Small', 'Medium', 'Large', 'XL', '50G',
        '100G', '250G', '500G', '1KG', '5KG'
    ) AS S
)
SELECT
    SEQ4() AS PRODUCT_SEED_ID,
    BL.B[MOD(SEQ4(), 30)]::VARCHAR AS BRAND,
    PL.P[MOD(SEQ4(), 30)]::VARCHAR AS PRODUCT_NAME,
    CL.C[MOD(SEQ4(), 10)]::VARCHAR AS CATEGORY,
    ML.M[MOD(SEQ4(), 15)]::VARCHAR AS MANUFACTURER,
    SL.S[MOD(SEQ4(), 15)]::VARCHAR AS SIZE,
    ROUND(UNIFORM(5.00, 999.99, RANDOM())::NUMBER(12,2), 2) AS BASE_PRICE,
    CASE
        WHEN MOD(SEQ4(), 10) < 4 THEN 'T0'
        WHEN MOD(SEQ4(), 10) < 7 THEN 'T1'
        WHEN MOD(SEQ4(), 10) < 9 THEN 'T2'
        ELSE 'T3'
    END AS RELATIONSHIP_TYPE
FROM TABLE(GENERATOR(ROWCOUNT => 10000)), BRAND_LIST BL, PRODUCT_LIST PL, CATEGORY_LIST CL, MANUFACTURER_LIST ML, SIZE_LIST SL;

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.ERP_PRODUCT (PRODUCT_CODE, BRAND_NAME, PRODUCT_DESCRIPTION, PRODUCT_CATEGORY, MANUFACTURER_NAME, LIST_PRICE, PRODUCT_SIZE, LOAD_DTTM)
SELECT
    'ERP-' || LPAD(PRODUCT_SEED_ID, 7, '0'),
    BRAND,
    PRODUCT_NAME || ' ' || SIZE,
    CATEGORY,
    CASE WHEN MOD(PRODUCT_SEED_ID, 25) = 0 THEN NULL ELSE MANUFACTURER END,
    BASE_PRICE,
    CASE WHEN MOD(PRODUCT_SEED_ID, 20) = 0 THEN NULL ELSE SIZE END,
    DATEADD('SECOND', -UNIFORM(0, 2592000, RANDOM()), CURRENT_TIMESTAMP())
FROM RELATIONSHIP_DISCOVERY_DB.SRC.PRODUCT_SEED;

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.ERP_PRODUCT (PRODUCT_CODE, BRAND_NAME, PRODUCT_DESCRIPTION, PRODUCT_CATEGORY, MANUFACTURER_NAME, LIST_PRICE, PRODUCT_SIZE, LOAD_DTTM)
WITH
ORPHAN_BRANDS AS (
    SELECT ARRAY_CONSTRUCT('OrphanBrand_A', 'OrphanBrand_B', 'OrphanBrand_C', 'OrphanBrand_D', 'OrphanBrand_E') AS B
),
ORPHAN_PRODUCTS AS (
    SELECT ARRAY_CONSTRUCT('UniqueItem', 'SpecialPart', 'CustomUnit', 'RareModule', 'ExclusiveKit') AS P
)
SELECT
    'ERP-O-' || LPAD(SEQ4(), 5, '0'),
    OB.B[MOD(SEQ4(), 5)]::VARCHAR,
    OP.P[MOD(SEQ4(), 5)]::VARCHAR || ' ' || MOD(SEQ4(), 100)::VARCHAR,
    'Specialty',
    'Orphan Manufacturer',
    ROUND(UNIFORM(10.00, 500.00, RANDOM())::NUMBER(12,2), 2),
    '500ML',
    DATEADD('SECOND', -UNIFORM(0, 2592000, RANDOM()), CURRENT_TIMESTAMP())
FROM TABLE(GENERATOR(ROWCOUNT => 250)), ORPHAN_BRANDS OB, ORPHAN_PRODUCTS OP;

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.SUPPLIER_PRODUCT (ITEM_CODE, ITEM_NAME, BRAND, CATEGORY_DESCRIPTION, MFG_NAME, UNIT_COST, PACK_SIZE, LOAD_DTTM)
SELECT
    'SUP-' || LPAD(PRODUCT_SEED_ID, 7, '0'),
    CASE
        WHEN RELATIONSHIP_TYPE = 'T0' THEN PRODUCT_NAME || ' ' || SIZE
        WHEN RELATIONSHIP_TYPE = 'T1' THEN 'Premium ' || PRODUCT_NAME || ' ' || SIZE
        WHEN RELATIONSHIP_TYPE = 'T2' THEN LEFT(PRODUCT_NAME, 3) || '-' || SIZE
        ELSE PRODUCT_NAME || ' ' || SIZE
    END,
    CASE
        WHEN RELATIONSHIP_TYPE = 'T0' THEN BRAND
        WHEN RELATIONSHIP_TYPE = 'T1' THEN BRAND || ' Corp'
        WHEN RELATIONSHIP_TYPE = 'T2' THEN UPPER(LEFT(BRAND, 4))
        WHEN RELATIONSHIP_TYPE = 'T3' THEN
            CASE MOD(PRODUCT_SEED_ID, 5)
                WHEN 0 THEN 'Nexus'
                WHEN 1 THEN 'Acme'
                WHEN 2 THEN 'Pinnacle'
                WHEN 3 THEN 'Vertex'
                ELSE 'Horizon'
            END
    END,
    CASE
        WHEN CATEGORY = 'Electronics' THEN 'Electronics/Components'
        WHEN CATEGORY = 'Industrial' THEN 'Industrial/Heavy'
        WHEN CATEGORY = 'Consumer Goods' THEN 'Consumer/FMCG'
        WHEN CATEGORY = 'Healthcare' THEN 'Healthcare/Medical'
        WHEN CATEGORY = 'Automotive' THEN 'Auto/Parts'
        WHEN CATEGORY = 'Home & Garden' THEN 'Home/Garden'
        WHEN CATEGORY = 'Office Supplies' THEN 'Office/Business'
        WHEN CATEGORY = 'Food & Beverage' THEN 'Food/Bev'
        WHEN CATEGORY = 'Personal Care' THEN 'Personal/Care'
        ELSE 'Cleaning/Chemical'
    END,
    CASE
        WHEN MOD(PRODUCT_SEED_ID, 12) = 0 THEN NULL
        WHEN RELATIONSHIP_TYPE = 'T0' THEN MANUFACTURER
        WHEN RELATIONSHIP_TYPE = 'T1' THEN LEFT(MANUFACTURER, POSITION(' ' IN MANUFACTURER || ' ') - 1)
        ELSE LEFT(MANUFACTURER, 3) || ' Mfg'
    END,
    ROUND((BASE_PRICE * UNIFORM(0.60, 0.85, RANDOM()))::NUMBER(12,2), 2),
    CASE
        WHEN MOD(PRODUCT_SEED_ID, 10) = 0 THEN NULL
        WHEN SIZE = '100ML' THEN '100ml'
        WHEN SIZE = '250ML' THEN '250ml'
        WHEN SIZE = '500ML' THEN '500ml'
        WHEN SIZE = '1L' THEN '1000ml'
        WHEN SIZE = '2L' THEN '2000ml'
        WHEN SIZE = 'Small' THEN 'SML'
        WHEN SIZE = 'Medium' THEN 'MED'
        WHEN SIZE = 'Large' THEN 'LRG'
        WHEN SIZE = 'XL' THEN 'XLG'
        WHEN SIZE = '50G' THEN '50g'
        WHEN SIZE = '100G' THEN '100g'
        WHEN SIZE = '250G' THEN '250g'
        WHEN SIZE = '500G' THEN '500g'
        WHEN SIZE = '1KG' THEN '1000g'
        ELSE '5000g'
    END,
    DATEADD('SECOND', -UNIFORM(0, 2592000, RANDOM()), CURRENT_TIMESTAMP())
FROM RELATIONSHIP_DISCOVERY_DB.SRC.PRODUCT_SEED;

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.SUPPLIER_PRODUCT (ITEM_CODE, ITEM_NAME, BRAND, CATEGORY_DESCRIPTION, MFG_NAME, UNIT_COST, PACK_SIZE, LOAD_DTTM)
WITH
ORPHAN_BRANDS AS (
    SELECT ARRAY_CONSTRUCT('SupplierOnly_A', 'SupplierOnly_B', 'SupplierOnly_C', 'SupplierOnly_D', 'SupplierOnly_E') AS B
),
ORPHAN_PRODUCTS AS (
    SELECT ARRAY_CONSTRUCT('BulkItem', 'WholesalePart', 'TradeGoods', 'DistributorPack', 'VendorSpecial') AS P
)
SELECT
    'SUP-O-' || LPAD(SEQ4(), 5, '0'),
    OP.P[MOD(SEQ4(), 5)]::VARCHAR || ' ' || MOD(SEQ4(), 200)::VARCHAR,
    OB.B[MOD(SEQ4(), 5)]::VARCHAR,
    'Wholesale/Bulk',
    'Supplier Mfg',
    ROUND(UNIFORM(5.00, 300.00, RANDOM())::NUMBER(12,2), 2),
    'BULK',
    DATEADD('SECOND', -UNIFORM(0, 2592000, RANDOM()), CURRENT_TIMESTAMP())
FROM TABLE(GENERATOR(ROWCOUNT => 800)), ORPHAN_BRANDS OB, ORPHAN_PRODUCTS OP;

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.INVENTORY_PRODUCT (SKU_CODE, SKU_DESCRIPTION, BRAND_CODE, STORAGE_CATEGORY, REORDER_COST, WEIGHT_SIZE, LOAD_DTTM)
SELECT
    'SKU-' || LPAD(PRODUCT_SEED_ID, 7, '0'),
    CASE
        WHEN RELATIONSHIP_TYPE = 'T0' THEN PRODUCT_NAME || ' ' || SIZE
        WHEN RELATIONSHIP_TYPE = 'T1' THEN PRODUCT_NAME || ' ' || SIZE || ' Industrial'
        WHEN RELATIONSHIP_TYPE = 'T2' THEN LEFT(PRODUCT_NAME, 3) || '-' || LPAD(MOD(PRODUCT_SEED_ID, 999)::VARCHAR, 3, '0')
        ELSE PRODUCT_NAME || '-' || MOD(PRODUCT_SEED_ID, 9999)::VARCHAR
    END,
    CASE
        WHEN RELATIONSHIP_TYPE = 'T0' THEN UPPER(LEFT(BRAND, 5))
        WHEN RELATIONSHIP_TYPE = 'T1' THEN UPPER(LEFT(BRAND, 5)) || '-' || MOD(PRODUCT_SEED_ID, 9)::VARCHAR
        WHEN RELATIONSHIP_TYPE = 'T2' THEN UPPER(LEFT(BRAND, 3))
        ELSE UPPER(LEFT(BRAND, 4)) || 'X'
    END,
    CASE
        WHEN CATEGORY = 'Electronics' THEN 'ELEC-STORE'
        WHEN CATEGORY = 'Industrial' THEN 'IND-STORE'
        WHEN CATEGORY = 'Consumer Goods' THEN 'CONS-STORE'
        WHEN CATEGORY = 'Healthcare' THEN 'MED-STORE'
        WHEN CATEGORY = 'Automotive' THEN 'AUTO-STORE'
        WHEN CATEGORY = 'Home & Garden' THEN 'HOME-STORE'
        WHEN CATEGORY = 'Office Supplies' THEN 'OFF-STORE'
        WHEN CATEGORY = 'Food & Beverage' THEN 'FOOD-STORE'
        WHEN CATEGORY = 'Personal Care' THEN 'PERS-STORE'
        ELSE 'CHEM-STORE'
    END,
    ROUND((BASE_PRICE * UNIFORM(0.40, 0.70, RANDOM()))::NUMBER(12,2), 2),
    CASE
        WHEN MOD(PRODUCT_SEED_ID, 8) = 0 THEN NULL
        WHEN SIZE = '100ML' THEN '0.1L'
        WHEN SIZE = '250ML' THEN '0.25L'
        WHEN SIZE = '500ML' THEN '0.5L'
        WHEN SIZE = '1L' THEN '1L'
        WHEN SIZE = '2L' THEN '2L'
        WHEN SIZE = 'Small' THEN 'S'
        WHEN SIZE = 'Medium' THEN 'M'
        WHEN SIZE = 'Large' THEN 'L'
        WHEN SIZE = 'XL' THEN 'XL'
        WHEN SIZE = '50G' THEN '50G'
        WHEN SIZE = '100G' THEN '0.1KG'
        WHEN SIZE = '250G' THEN '0.25KG'
        WHEN SIZE = '500G' THEN '0.5KG'
        WHEN SIZE = '1KG' THEN '1KG'
        ELSE '5KG'
    END,
    DATEADD('SECOND', -UNIFORM(0, 2592000, RANDOM()), CURRENT_TIMESTAMP())
FROM RELATIONSHIP_DISCOVERY_DB.SRC.PRODUCT_SEED;

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.INVENTORY_PRODUCT (SKU_CODE, SKU_DESCRIPTION, BRAND_CODE, STORAGE_CATEGORY, REORDER_COST, WEIGHT_SIZE, LOAD_DTTM)
WITH
ORPHAN_BRANDS AS (
    SELECT ARRAY_CONSTRUCT('WHONLY', 'INVONLY', 'SKUEX', 'STKSP', 'WRHSE') AS B
),
ORPHAN_PRODUCTS AS (
    SELECT ARRAY_CONSTRUCT('PalletUnit', 'BinStock', 'ShelfItem', 'CrateGoods', 'RackPart') AS P
)
SELECT
    'SKU-O-' || LPAD(SEQ4(), 5, '0'),
    OP.P[MOD(SEQ4(), 5)]::VARCHAR || '-' || MOD(SEQ4(), 500)::VARCHAR,
    OB.B[MOD(SEQ4(), 5)]::VARCHAR,
    'WAREHOUSE-ONLY',
    ROUND(UNIFORM(1.00, 200.00, RANDOM())::NUMBER(12,2), 2),
    'BULK',
    DATEADD('SECOND', -UNIFORM(0, 2592000, RANDOM()), CURRENT_TIMESTAMP())
FROM TABLE(GENERATOR(ROWCOUNT => 450)), ORPHAN_BRANDS OB, ORPHAN_PRODUCTS OP;

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.ECOMMERCE_PRODUCT (VENDOR_CODE, LISTING_TITLE, VENDOR_NAME, WEB_CATEGORY, SELLER_NAME, SELLING_PRICE, DISPLAY_SIZE, LOAD_DTTM)
WITH
SELLER_LIST AS (
    SELECT ARRAY_CONSTRUCT(
        'Global Manufacturing Co', 'Pacific Industries LLC', 'Continental Corporation', 'National Products Inc', 'Premier Manufacturing Group',
        'Allied Industries Ltd', 'Standard Corporation', 'Universal Manufacturing Co', 'Delta Industries Inc', 'Omega Corporation',
        'TechDirect Store', 'MegaSupply Hub', 'ValueMax Outlet', 'PrimeParts Direct', 'QuickShip Warehouse'
    ) AS SL
)
SELECT
    'ECOM-' || LPAD(PS.PRODUCT_SEED_ID, 7, '0'),
    CASE
        WHEN PS.RELATIONSHIP_TYPE = 'T0' THEN PS.BRAND || ' ' || PS.PRODUCT_NAME || ' - ' || PS.SIZE
        WHEN PS.RELATIONSHIP_TYPE = 'T1' THEN 'NEW ' || PS.BRAND || ' ' || PS.PRODUCT_NAME || ' ' || PS.SIZE || ' - Free Shipping'
        WHEN PS.RELATIONSHIP_TYPE = 'T2' THEN PS.PRODUCT_NAME || ' by ' || LEFT(PS.BRAND, 3) || ' (' || PS.SIZE || ')'
        ELSE PS.BRAND || ' Premium ' || PS.PRODUCT_NAME || ' #' || MOD(PS.PRODUCT_SEED_ID, 999)::VARCHAR
    END,
    CASE
        WHEN PS.RELATIONSHIP_TYPE = 'T0' THEN PS.BRAND
        WHEN PS.RELATIONSHIP_TYPE = 'T1' THEN PS.BRAND || ' Official Store'
        WHEN PS.RELATIONSHIP_TYPE = 'T2' THEN LOWER(PS.BRAND)
        ELSE
            CASE MOD(PS.PRODUCT_SEED_ID, 5)
                WHEN 0 THEN 'Meridian'
                WHEN 1 THEN 'Cobalt'
                WHEN 2 THEN 'Eclipse'
                WHEN 3 THEN 'Fusion'
                ELSE 'Catalyst'
            END
    END,
    CASE
        WHEN PS.CATEGORY = 'Electronics' THEN 'Electronics & Gadgets'
        WHEN PS.CATEGORY = 'Industrial' THEN 'Industrial & Scientific'
        WHEN PS.CATEGORY = 'Consumer Goods' THEN 'Consumer Products'
        WHEN PS.CATEGORY = 'Healthcare' THEN 'Health & Wellness'
        WHEN PS.CATEGORY = 'Automotive' THEN 'Automotive Parts'
        WHEN PS.CATEGORY = 'Home & Garden' THEN 'Home & Garden'
        WHEN PS.CATEGORY = 'Office Supplies' THEN 'Office & School'
        WHEN PS.CATEGORY = 'Food & Beverage' THEN 'Food & Grocery'
        WHEN PS.CATEGORY = 'Personal Care' THEN 'Beauty & Personal Care'
        ELSE 'Cleaning Supplies'
    END,
    CASE
        WHEN MOD(PS.PRODUCT_SEED_ID, 10) = 0 THEN NULL
        ELSE SLR.SL[MOD(PS.PRODUCT_SEED_ID, 15)]::VARCHAR
    END,
    ROUND((PS.BASE_PRICE * UNIFORM(1.10, 1.50, RANDOM()))::NUMBER(12,2), 2),
    CASE
        WHEN MOD(PS.PRODUCT_SEED_ID, 12) = 0 THEN NULL
        WHEN PS.SIZE = '100ML' THEN '100 Milliliters'
        WHEN PS.SIZE = '250ML' THEN '250 Milliliters'
        WHEN PS.SIZE = '500ML' THEN '500 Milliliters'
        WHEN PS.SIZE = '1L' THEN '1 Liter'
        WHEN PS.SIZE = '2L' THEN '2 Liters'
        WHEN PS.SIZE = 'Small' THEN 'Small Size'
        WHEN PS.SIZE = 'Medium' THEN 'Medium Size'
        WHEN PS.SIZE = 'Large' THEN 'Large Size'
        WHEN PS.SIZE = 'XL' THEN 'Extra Large'
        WHEN PS.SIZE = '50G' THEN '50 Grams'
        WHEN PS.SIZE = '100G' THEN '100 Grams'
        WHEN PS.SIZE = '250G' THEN '250 Grams'
        WHEN PS.SIZE = '500G' THEN '500 Grams'
        WHEN PS.SIZE = '1KG' THEN '1 Kilogram'
        ELSE '5 Kilograms'
    END,
    DATEADD('SECOND', -UNIFORM(0, 2592000, RANDOM()), CURRENT_TIMESTAMP())
FROM RELATIONSHIP_DISCOVERY_DB.SRC.PRODUCT_SEED PS, SELLER_LIST SLR;

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.ECOMMERCE_PRODUCT (VENDOR_CODE, LISTING_TITLE, VENDOR_NAME, WEB_CATEGORY, SELLER_NAME, SELLING_PRICE, DISPLAY_SIZE, LOAD_DTTM)
WITH
ORPHAN_BRANDS AS (
    SELECT ARRAY_CONSTRUCT('WebExclusive', 'OnlineOnly', 'DigitalDeal', 'FlashSale', 'MarketplaceSpecial') AS B
),
ORPHAN_PRODUCTS AS (
    SELECT ARRAY_CONSTRUCT('Bundle Pack', 'Starter Kit', 'Value Set', 'Gift Box', 'Trial Size') AS P
)
SELECT
    'ECOM-O-' || LPAD(SEQ4(), 5, '0'),
    OB.B[MOD(SEQ4(), 5)]::VARCHAR || ' ' || OP.P[MOD(SEQ4(), 5)]::VARCHAR || ' - Limited Edition #' || MOD(SEQ4(), 999)::VARCHAR,
    OB.B[MOD(SEQ4(), 5)]::VARCHAR,
    'Marketplace Exclusives',
    'Online Seller ' || MOD(SEQ4(), 50)::VARCHAR,
    ROUND(UNIFORM(9.99, 299.99, RANDOM())::NUMBER(12,2), 2),
    'One Size',
    DATEADD('SECOND', -UNIFORM(0, 2592000, RANDOM()), CURRENT_TIMESTAMP())
FROM TABLE(GENERATOR(ROWCOUNT => 950)), ORPHAN_BRANDS OB, ORPHAN_PRODUCTS OP;
