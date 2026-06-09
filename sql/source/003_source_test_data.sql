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

----------------------------------------------------------------------
-- SHOWCASE RECORDS: Curated cross-system matches for demo
-- 20 products appear in ALL 4 systems with realistic T0/T1/T2 variations
-- Guarantees "hero records" for Before/After demo in Live Explorer
--
-- Match patterns engineered:
--   T0 (Exact): Same BRAND + PRODUCT_NAME across systems
--   T1 (Fuzzy): PRODUCT_NAME contains/is-contained-by another
--   T2 (Prefix): First 3 chars of BRAND match (inventory codes)
--   Cross-system: Different CATEGORY naming, SIZE formatting, PRICE tiers
----------------------------------------------------------------------

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.ERP_PRODUCT (PRODUCT_CODE, BRAND_NAME, PRODUCT_DESCRIPTION, PRODUCT_CATEGORY, MANUFACTURER_NAME, LIST_PRICE, PRODUCT_SIZE, LOAD_DTTM)
VALUES
('ERP-DEMO-001', 'Procter & Gamble', 'Detergent 1L', 'Consumer Goods', 'Global Manufacturing Co', 24.99, '1L', CURRENT_TIMESTAMP()),
('ERP-DEMO-002', 'Johnson & Johnson', 'Sanitizer 500ML', 'Healthcare', 'Premier Manufacturing', 12.49, '500ML', CURRENT_TIMESTAMP()),
('ERP-DEMO-003', 'Unilever', 'Cleaner 2L', 'Cleaning', 'Continental Corp', 18.99, '2L', CURRENT_TIMESTAMP()),
('ERP-DEMO-004', 'Colgate', 'Polish 250G', 'Personal Care', 'National Products Inc', 8.99, '250G', CURRENT_TIMESTAMP()),
('ERP-DEMO-005', 'Henkel', 'Adhesive 100ML', 'Industrial', 'Pacific Industries', 34.99, '100ML', CURRENT_TIMESTAMP()),
('ERP-DEMO-006', 'Kimberly Clark', 'Filter Large', 'Consumer Goods', 'Allied Industries', 42.50, 'Large', CURRENT_TIMESTAMP()),
('ERP-DEMO-007', 'Reckitt', 'Pump 500G', 'Healthcare', 'Standard Corp', 29.99, '500G', CURRENT_TIMESTAMP()),
('ERP-DEMO-008', 'Acme', 'Widget 250ML', 'Electronics', 'Universal Manufacturing', 15.99, '250ML', CURRENT_TIMESTAMP()),
('ERP-DEMO-009', 'Nexus', 'Controller 1KG', 'Industrial', 'Delta Industries', 89.99, '1KG', CURRENT_TIMESTAMP()),
('ERP-DEMO-010', 'Pinnacle', 'Sensor Medium', 'Automotive', 'Omega Corp', 55.00, 'Medium', CURRENT_TIMESTAMP()),
('ERP-DEMO-011', 'Clorox', 'Solvent 5KG', 'Cleaning', 'Eastern Manufacturing', 67.50, '5KG', CURRENT_TIMESTAMP()),
('ERP-DEMO-012', 'Church & Dwight', 'Coating 500ML', 'Home & Garden', 'Western Industries', 22.99, '500ML', CURRENT_TIMESTAMP()),
('ERP-DEMO-013', 'Atlas', 'Motor Small', 'Automotive', 'Northern Corp', 120.00, 'Small', CURRENT_TIMESTAMP()),
('ERP-DEMO-014', 'Titan', 'Drive XL', 'Industrial', 'Southern Products', 199.99, 'XL', CURRENT_TIMESTAMP()),
('ERP-DEMO-015', 'Summit', 'Bracket 100G', 'Office Supplies', 'Central Manufacturing', 7.50, '100G', CURRENT_TIMESTAMP()),
('ERP-DEMO-016', 'Horizon', 'Relay 50G', 'Electronics', 'Global Manufacturing Co', 45.00, '50G', CURRENT_TIMESTAMP()),
('ERP-DEMO-017', 'Nova', 'Switch 1L', 'Consumer Goods', 'Pacific Industries', 33.99, '1L', CURRENT_TIMESTAMP()),
('ERP-DEMO-018', 'Apex', 'Processor Medium', 'Electronics', 'Continental Corp', 149.99, 'Medium', CURRENT_TIMESTAMP()),
('ERP-DEMO-019', 'Vertex', 'Adapter 250G', 'Industrial', 'Premier Manufacturing', 28.00, '250G', CURRENT_TIMESTAMP()),
('ERP-DEMO-020', 'Fusion', 'Lubricant 2L', 'Automotive', 'National Products Inc', 38.99, '2L', CURRENT_TIMESTAMP());

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.SUPPLIER_PRODUCT (ITEM_CODE, BRAND, ITEM_NAME, CATEGORY_DESCRIPTION, MFG_NAME, UNIT_COST, PACK_SIZE, LOAD_DTTM)
VALUES
('SUP-DEMO-001', 'Procter & Gamble', 'Detergent 1L', 'Consumer/FMCG', 'Global Manufacturing Co', 18.50, '1000ml', CURRENT_TIMESTAMP()),
('SUP-DEMO-002', 'Johnson & Johnson', 'Sanitizer 500ML', 'Healthcare/Medical', 'Premier', 9.20, '500ml', CURRENT_TIMESTAMP()),
('SUP-DEMO-003', 'Unilever', 'Premium Cleaner 2L', 'Cleaning/Chemical', 'Continental', 14.10, '2000ml', CURRENT_TIMESTAMP()),
('SUP-DEMO-004', 'Colgate', 'Polish 250G', 'Personal/Care', 'National', 6.50, '250g', CURRENT_TIMESTAMP()),
('SUP-DEMO-005', 'Henkel', 'Industrial Adhesive 100ML', 'Industrial/Heavy', 'Pacific', 26.00, '100ml', CURRENT_TIMESTAMP()),
('SUP-DEMO-006', 'Kimberly Clark', 'Premium Filter Large', 'Consumer/FMCG', 'Allied', 32.00, 'LRG', CURRENT_TIMESTAMP()),
('SUP-DEMO-007', 'Reckitt', 'Pump 500G', 'Healthcare/Medical', 'Standard Corp', 22.50, '500g', CURRENT_TIMESTAMP()),
('SUP-DEMO-008', 'Acme', 'Widget 250ML', 'Electronics/Components', 'Universal', 11.80, '250ml', CURRENT_TIMESTAMP()),
('SUP-DEMO-009', 'Nexus', 'Controller 1KG', 'Industrial/Heavy', 'Delta', 67.00, '1000g', CURRENT_TIMESTAMP()),
('SUP-DEMO-010', 'Pinnacle', 'Sensor Medium', 'Auto/Parts', 'Omega', 41.00, 'MED', CURRENT_TIMESTAMP()),
('SUP-DEMO-011', 'Clorox', 'Solvent 5KG', 'Cleaning/Chemical', 'Eastern', 50.00, '5000g', CURRENT_TIMESTAMP()),
('SUP-DEMO-012', 'Church & Dwight', 'Premium Coating 500ML', 'Home/Garden', 'Western', 17.00, '500ml', CURRENT_TIMESTAMP()),
('SUP-DEMO-013', 'Atlas', 'Motor Small', 'Auto/Parts', 'Northern Corp', 90.00, 'SML', CURRENT_TIMESTAMP()),
('SUP-DEMO-014', 'Titan', 'Heavy Drive XL', 'Industrial/Heavy', 'Southern', 150.00, 'XLG', CURRENT_TIMESTAMP()),
('SUP-DEMO-015', 'Summit', 'Bracket 100G', 'Office/Business', 'Central', 5.50, '100g', CURRENT_TIMESTAMP()),
('SUP-DEMO-016', 'Horizon', 'Relay 50G', 'Electronics/Components', 'Global', 33.50, '50g', CURRENT_TIMESTAMP()),
('SUP-DEMO-017', 'Nova', 'Switch 1L', 'Consumer/FMCG', 'Pacific', 25.00, '1000ml', CURRENT_TIMESTAMP()),
('SUP-DEMO-018', 'Apex', 'Processor Medium', 'Electronics/Components', 'Continental', 112.00, 'MED', CURRENT_TIMESTAMP()),
('SUP-DEMO-019', 'Vertex', 'Adapter 250G', 'Industrial/Heavy', 'Premier', 21.00, '250g', CURRENT_TIMESTAMP()),
('SUP-DEMO-020', 'Fusion', 'Lubricant 2L', 'Auto/Parts', 'National', 29.00, '2000ml', CURRENT_TIMESTAMP());

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.INVENTORY_PRODUCT (SKU_CODE, BRAND_CODE, SKU_DESCRIPTION, STORAGE_CATEGORY, REORDER_COST, WEIGHT_SIZE, LOAD_DTTM)
VALUES
('SKU-DEMO-001', 'PROCT', 'Detergent 1L', 'CONS-STORE', 15.00, '1L', CURRENT_TIMESTAMP()),
('SKU-DEMO-002', 'JOHNS', 'Sanitizer 500ML', 'MED-STORE', 7.50, '0.5L', CURRENT_TIMESTAMP()),
('SKU-DEMO-003', 'UNILE', 'Cleaner 2L', 'CHEM-STORE', 11.50, '2L', CURRENT_TIMESTAMP()),
('SKU-DEMO-004', 'COLGA', 'Polish 250G', 'PERS-STORE', 5.00, '0.25KG', CURRENT_TIMESTAMP()),
('SKU-DEMO-005', 'HENKE', 'Adhesive 100ML', 'IND-STORE', 20.00, '0.1L', CURRENT_TIMESTAMP()),
('SKU-DEMO-006', 'KIMBE', 'Filter Large', 'CONS-STORE', 25.00, 'L', CURRENT_TIMESTAMP()),
('SKU-DEMO-007', 'RECKI', 'Pump 500G', 'MED-STORE', 18.00, '0.5KG', CURRENT_TIMESTAMP()),
('SKU-DEMO-008', 'ACME', 'Widget 250ML', 'ELEC-STORE', 9.50, '0.25L', CURRENT_TIMESTAMP()),
('SKU-DEMO-009', 'NEXUS', 'Controller 1KG', 'IND-STORE', 52.00, '1KG', CURRENT_TIMESTAMP()),
('SKU-DEMO-010', 'PINNA', 'Sensor Medium', 'AUTO-STORE', 33.00, 'M', CURRENT_TIMESTAMP()),
('SKU-DEMO-011', 'CLORO', 'Solvent 5KG', 'CHEM-STORE', 40.00, '5KG', CURRENT_TIMESTAMP()),
('SKU-DEMO-012', 'CHURC', 'Coating 500ML', 'HOME-STORE', 13.50, '0.5L', CURRENT_TIMESTAMP()),
('SKU-DEMO-013', 'ATLAS', 'Motor Small', 'AUTO-STORE', 72.00, 'S', CURRENT_TIMESTAMP()),
('SKU-DEMO-014', 'TITAN', 'Drive XL', 'IND-STORE', 120.00, 'XL', CURRENT_TIMESTAMP()),
('SKU-DEMO-015', 'SUMMI', 'Bracket 100G', 'OFF-STORE', 4.50, '0.1KG', CURRENT_TIMESTAMP()),
('SKU-DEMO-016', 'HORIZ', 'Relay 50G', 'ELEC-STORE', 27.00, '50G', CURRENT_TIMESTAMP()),
('SKU-DEMO-017', 'NOVA', 'Switch 1L', 'CONS-STORE', 20.00, '1L', CURRENT_TIMESTAMP()),
('SKU-DEMO-018', 'APEX', 'Processor Medium', 'ELEC-STORE', 85.00, 'M', CURRENT_TIMESTAMP()),
('SKU-DEMO-019', 'VERTE', 'Adapter 250G', 'IND-STORE', 16.50, '0.25KG', CURRENT_TIMESTAMP()),
('SKU-DEMO-020', 'FUSIO', 'Lubricant 2L', 'AUTO-STORE', 23.00, '2L', CURRENT_TIMESTAMP());

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.ECOMMERCE_PRODUCT (VENDOR_CODE, LISTING_TITLE, VENDOR_NAME, WEB_CATEGORY, SELLER_NAME, SELLING_PRICE, DISPLAY_SIZE, LOAD_DTTM)
VALUES
('ECOM-DEMO-001', 'Procter & Gamble Detergent - 1 Liter', 'Procter & Gamble', 'Consumer Products', 'MegaSupply Hub', 29.99, '1 Liter', CURRENT_TIMESTAMP()),
('ECOM-DEMO-002', 'J&J Sanitizer 500ml - Fast Shipping', 'Johnson & Johnson', 'Health & Wellness', 'PrimeParts Direct', 15.99, '500 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-DEMO-003', 'Unilever All-Purpose Cleaner 2L', 'Unilever', 'Cleaning Supplies', 'ValueMax Outlet', 23.99, '2 Liters', CURRENT_TIMESTAMP()),
('ECOM-DEMO-004', 'Colgate Premium Polish 250g', 'Colgate', 'Beauty & Personal Care', 'QuickShip Warehouse', 11.49, '250 Grams', CURRENT_TIMESTAMP()),
('ECOM-DEMO-005', 'Henkel Industrial Adhesive 100ml', 'Henkel', 'Industrial & Scientific', 'TechDirect Store', 42.99, '100 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-DEMO-006', 'Kimberly Clark Filter - Large Size', 'Kimberly Clark', 'Consumer Products', 'MegaSupply Hub', 54.99, 'Large Size', CURRENT_TIMESTAMP()),
('ECOM-DEMO-007', 'Reckitt Medical Pump 500g', 'Reckitt', 'Health & Wellness', 'PrimeParts Direct', 37.99, '500 Grams', CURRENT_TIMESTAMP()),
('ECOM-DEMO-008', 'Acme Widget 250ml - Best Seller', 'Acme', 'Electronics & Gadgets', 'TechDirect Store', 19.99, '250 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-DEMO-009', 'Nexus Industrial Controller 1kg', 'Nexus', 'Industrial & Scientific', 'Global Manufacturing Co', 109.99, '1 Kilogram', CURRENT_TIMESTAMP()),
('ECOM-DEMO-010', 'Pinnacle Auto Sensor - Medium', 'Pinnacle', 'Automotive Parts', 'QuickShip Warehouse', 69.99, 'Medium Size', CURRENT_TIMESTAMP()),
('ECOM-DEMO-011', 'Clorox Heavy Duty Solvent 5kg', 'Clorox', 'Cleaning Supplies', 'ValueMax Outlet', 84.99, '5 Kilograms', CURRENT_TIMESTAMP()),
('ECOM-DEMO-012', 'Church & Dwight Coating 500ml', 'Church & Dwight', 'Home & Garden', 'MegaSupply Hub', 28.99, '500 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-DEMO-013', 'Atlas Performance Motor - Small', 'Atlas', 'Automotive Parts', 'PrimeParts Direct', 149.99, 'Small Size', CURRENT_TIMESTAMP()),
('ECOM-DEMO-014', 'Titan XL Drive - Industrial Grade', 'Titan', 'Industrial & Scientific', 'TechDirect Store', 249.99, 'Extra Large', CURRENT_TIMESTAMP()),
('ECOM-DEMO-015', 'Summit Office Bracket 100g', 'Summit', 'Office & School', 'QuickShip Warehouse', 9.99, '100 Grams', CURRENT_TIMESTAMP()),
('ECOM-DEMO-016', 'Horizon Relay 50g - Precision', 'Horizon', 'Electronics & Gadgets', 'TechDirect Store', 57.99, '50 Grams', CURRENT_TIMESTAMP()),
('ECOM-DEMO-017', 'Nova Switch 1L - Premium', 'Nova', 'Consumer Products', 'MegaSupply Hub', 42.99, '1 Liter', CURRENT_TIMESTAMP()),
('ECOM-DEMO-018', 'Apex Processor Medium - Pro Series', 'Apex', 'Electronics & Gadgets', 'Global Manufacturing Co', 189.99, 'Medium Size', CURRENT_TIMESTAMP()),
('ECOM-DEMO-019', 'Vertex Industrial Adapter 250g', 'Vertex', 'Industrial & Scientific', 'PrimeParts Direct', 35.99, '250 Grams', CURRENT_TIMESTAMP()),
('ECOM-DEMO-020', 'Fusion Auto Lubricant 2L', 'Fusion', 'Automotive Parts', 'QuickShip Warehouse', 48.99, '2 Liters', CURRENT_TIMESTAMP());

----------------------------------------------------------------------
-- HERO RECORDS BATCH 2: Additional 30 cross-system products
----------------------------------------------------------------------

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.ERP_PRODUCT (PRODUCT_CODE, BRAND_NAME, PRODUCT_DESCRIPTION, PRODUCT_CATEGORY, MANUFACTURER_NAME, LIST_PRICE, PRODUCT_SIZE, LOAD_DTTM)
VALUES
('ERP-HERO-021', 'Procter & Gamble', 'Dishwash 750ML', 'Consumer Goods', 'Global Manufacturing Co', 14.99, '750ML', CURRENT_TIMESTAMP()),
('ERP-HERO-022', 'Procter & Gamble', 'Fabric Softener 2L', 'Consumer Goods', 'Global Manufacturing Co', 19.99, '2L', CURRENT_TIMESTAMP()),
('ERP-HERO-023', 'Johnson & Johnson', 'Bandage Large', 'Healthcare', 'Premier Manufacturing', 7.99, 'Large', CURRENT_TIMESTAMP()),
('ERP-HERO-024', 'Johnson & Johnson', 'Shampoo 500ML', 'Personal Care', 'Premier Manufacturing', 11.99, '500ML', CURRENT_TIMESTAMP()),
('ERP-HERO-025', 'Unilever', 'Soap Bar 100G', 'Personal Care', 'Continental Corp', 3.99, '100G', CURRENT_TIMESTAMP()),
('ERP-HERO-026', 'Unilever', 'Moisturizer 200ML', 'Personal Care', 'Continental Corp', 16.49, '200ML', CURRENT_TIMESTAMP()),
('ERP-HERO-027', 'Colgate', 'Toothpaste 150G', 'Personal Care', 'National Products Inc', 5.49, '150G', CURRENT_TIMESTAMP()),
('ERP-HERO-028', 'Colgate', 'Mouthwash 500ML', 'Personal Care', 'National Products Inc', 8.99, '500ML', CURRENT_TIMESTAMP()),
('ERP-HERO-029', 'Henkel', 'Sealant 300ML', 'Industrial', 'Pacific Industries', 22.99, '300ML', CURRENT_TIMESTAMP()),
('ERP-HERO-030', 'Henkel', 'Epoxy 500G', 'Industrial', 'Pacific Industries', 45.99, '500G', CURRENT_TIMESTAMP()),
('ERP-HERO-031', 'Acme', 'Gadget 100G', 'Electronics', 'Universal Manufacturing', 29.99, '100G', CURRENT_TIMESTAMP()),
('ERP-HERO-032', 'Acme', 'Module 500ML', 'Electronics', 'Universal Manufacturing', 44.99, '500ML', CURRENT_TIMESTAMP()),
('ERP-HERO-033', 'Nexus', 'Valve 250G', 'Industrial', 'Delta Industries', 62.00, '250G', CURRENT_TIMESTAMP()),
('ERP-HERO-034', 'Nexus', 'Bearing 1KG', 'Industrial', 'Delta Industries', 95.00, '1KG', CURRENT_TIMESTAMP()),
('ERP-HERO-035', 'Pinnacle', 'Brake Pad Medium', 'Automotive', 'Omega Corp', 78.00, 'Medium', CURRENT_TIMESTAMP()),
('ERP-HERO-036', 'Pinnacle', 'Spark Plug Small', 'Automotive', 'Omega Corp', 12.50, 'Small', CURRENT_TIMESTAMP()),
('ERP-HERO-037', 'Clorox', 'Bleach 1L', 'Cleaning', 'Eastern Manufacturing', 9.99, '1L', CURRENT_TIMESTAMP()),
('ERP-HERO-038', 'Clorox', 'Disinfectant 2L', 'Cleaning', 'Eastern Manufacturing', 15.99, '2L', CURRENT_TIMESTAMP()),
('ERP-HERO-039', 'Atlas', 'Alternator Large', 'Automotive', 'Northern Corp', 185.00, 'Large', CURRENT_TIMESTAMP()),
('ERP-HERO-040', 'Atlas', 'Starter Medium', 'Automotive', 'Northern Corp', 145.00, 'Medium', CURRENT_TIMESTAMP()),
('ERP-HERO-041', 'Titan', 'Compressor 5KG', 'Industrial', 'Southern Products', 320.00, '5KG', CURRENT_TIMESTAMP()),
('ERP-HERO-042', 'Titan', 'Turbine Large', 'Industrial', 'Southern Products', 450.00, 'Large', CURRENT_TIMESTAMP()),
('ERP-HERO-043', 'Summit', 'Stapler Medium', 'Office Supplies', 'Central Manufacturing', 18.00, 'Medium', CURRENT_TIMESTAMP()),
('ERP-HERO-044', 'Summit', 'Binder Large', 'Office Supplies', 'Central Manufacturing', 12.00, 'Large', CURRENT_TIMESTAMP()),
('ERP-HERO-045', 'Horizon', 'Capacitor 25G', 'Electronics', 'Global Manufacturing Co', 8.50, '25G', CURRENT_TIMESTAMP()),
('ERP-HERO-046', 'Horizon', 'Transistor 10G', 'Electronics', 'Global Manufacturing Co', 4.99, '10G', CURRENT_TIMESTAMP()),
('ERP-HERO-047', 'Nova', 'Connector 50G', 'Electronics', 'Pacific Industries', 22.00, '50G', CURRENT_TIMESTAMP()),
('ERP-HERO-048', 'Nova', 'Cable 5M', 'Electronics', 'Pacific Industries', 15.00, '5M', CURRENT_TIMESTAMP()),
('ERP-HERO-049', 'Vertex', 'Coupling 500G', 'Industrial', 'Premier Manufacturing', 56.00, '500G', CURRENT_TIMESTAMP()),
('ERP-HERO-050', 'Vertex', 'Flange 1KG', 'Industrial', 'Premier Manufacturing', 72.00, '1KG', CURRENT_TIMESTAMP());

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.SUPPLIER_PRODUCT (ITEM_CODE, BRAND, ITEM_NAME, CATEGORY_DESCRIPTION, MFG_NAME, UNIT_COST, PACK_SIZE, LOAD_DTTM)
VALUES
('SUP-HERO-021', 'Procter & Gamble', 'Dishwash 750ML', 'Consumer/FMCG', 'Global Manufacturing Co', 11.00, '750ml', CURRENT_TIMESTAMP()),
('SUP-HERO-022', 'Procter & Gamble', 'Fabric Softener 2L', 'Consumer/FMCG', 'Global', 15.00, '2000ml', CURRENT_TIMESTAMP()),
('SUP-HERO-023', 'Johnson & Johnson', 'Bandage Large', 'Healthcare/Medical', 'Premier', 5.80, 'LRG', CURRENT_TIMESTAMP()),
('SUP-HERO-024', 'Johnson & Johnson', 'Shampoo 500ML', 'Personal/Care', 'Premier', 8.90, '500ml', CURRENT_TIMESTAMP()),
('SUP-HERO-025', 'Unilever', 'Soap Bar 100G', 'Personal/Care', 'Continental', 2.80, '100g', CURRENT_TIMESTAMP()),
('SUP-HERO-026', 'Unilever', 'Moisturizer 200ML', 'Personal/Care', 'Continental', 12.20, '200ml', CURRENT_TIMESTAMP()),
('SUP-HERO-027', 'Colgate', 'Toothpaste 150G', 'Personal/Care', 'National', 3.90, '150g', CURRENT_TIMESTAMP()),
('SUP-HERO-028', 'Colgate', 'Mouthwash 500ML', 'Personal/Care', 'National', 6.50, '500ml', CURRENT_TIMESTAMP()),
('SUP-HERO-029', 'Henkel', 'Industrial Sealant 300ML', 'Industrial/Heavy', 'Pacific', 17.00, '300ml', CURRENT_TIMESTAMP()),
('SUP-HERO-030', 'Henkel', 'Epoxy 500G', 'Industrial/Heavy', 'Pacific', 34.00, '500g', CURRENT_TIMESTAMP()),
('SUP-HERO-031', 'Acme', 'Gadget 100G', 'Electronics/Components', 'Universal', 22.00, '100g', CURRENT_TIMESTAMP()),
('SUP-HERO-032', 'Acme', 'Module 500ML', 'Electronics/Components', 'Universal', 33.00, '500ml', CURRENT_TIMESTAMP()),
('SUP-HERO-033', 'Nexus', 'Valve 250G', 'Industrial/Heavy', 'Delta', 46.00, '250g', CURRENT_TIMESTAMP()),
('SUP-HERO-034', 'Nexus', 'Bearing 1KG', 'Industrial/Heavy', 'Delta', 71.00, '1000g', CURRENT_TIMESTAMP()),
('SUP-HERO-035', 'Pinnacle', 'Brake Pad Medium', 'Auto/Parts', 'Omega', 58.00, 'MED', CURRENT_TIMESTAMP()),
('SUP-HERO-036', 'Pinnacle', 'Spark Plug Small', 'Auto/Parts', 'Omega', 9.20, 'SML', CURRENT_TIMESTAMP()),
('SUP-HERO-037', 'Clorox', 'Bleach 1L', 'Cleaning/Chemical', 'Eastern', 7.20, '1000ml', CURRENT_TIMESTAMP()),
('SUP-HERO-038', 'Clorox', 'Disinfectant 2L', 'Cleaning/Chemical', 'Eastern', 11.80, '2000ml', CURRENT_TIMESTAMP()),
('SUP-HERO-039', 'Atlas', 'Alternator Large', 'Auto/Parts', 'Northern Corp', 140.00, 'LRG', CURRENT_TIMESTAMP()),
('SUP-HERO-040', 'Atlas', 'Starter Medium', 'Auto/Parts', 'Northern Corp', 108.00, 'MED', CURRENT_TIMESTAMP()),
('SUP-HERO-041', 'Titan', 'Compressor 5KG', 'Industrial/Heavy', 'Southern', 240.00, '5000g', CURRENT_TIMESTAMP()),
('SUP-HERO-042', 'Titan', 'Turbine Large', 'Industrial/Heavy', 'Southern', 340.00, 'LRG', CURRENT_TIMESTAMP()),
('SUP-HERO-043', 'Summit', 'Stapler Medium', 'Office/Business', 'Central', 13.50, 'MED', CURRENT_TIMESTAMP()),
('SUP-HERO-044', 'Summit', 'Binder Large', 'Office/Business', 'Central', 9.00, 'LRG', CURRENT_TIMESTAMP()),
('SUP-HERO-045', 'Horizon', 'Capacitor 25G', 'Electronics/Components', 'Global', 6.20, '25g', CURRENT_TIMESTAMP()),
('SUP-HERO-046', 'Horizon', 'Transistor 10G', 'Electronics/Components', 'Global', 3.60, '10g', CURRENT_TIMESTAMP()),
('SUP-HERO-047', 'Nova', 'Connector 50G', 'Electronics/Components', 'Pacific', 16.50, '50g', CURRENT_TIMESTAMP()),
('SUP-HERO-048', 'Nova', 'Cable 5M', 'Electronics/Components', 'Pacific', 11.00, '5m', CURRENT_TIMESTAMP()),
('SUP-HERO-049', 'Vertex', 'Coupling 500G', 'Industrial/Heavy', 'Premier', 42.00, '500g', CURRENT_TIMESTAMP()),
('SUP-HERO-050', 'Vertex', 'Flange 1KG', 'Industrial/Heavy', 'Premier', 54.00, '1000g', CURRENT_TIMESTAMP());

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.INVENTORY_PRODUCT (SKU_CODE, BRAND_CODE, SKU_DESCRIPTION, STORAGE_CATEGORY, REORDER_COST, WEIGHT_SIZE, LOAD_DTTM)
VALUES
('SKU-HERO-021', 'PROCT', 'Dishwash 750ML', 'CONS-STORE', 9.00, '750ML', CURRENT_TIMESTAMP()),
('SKU-HERO-022', 'PROCT', 'Fabric Softener 2L', 'CONS-STORE', 12.00, '2L', CURRENT_TIMESTAMP()),
('SKU-HERO-023', 'JOHNS', 'Bandage Large', 'MED-STORE', 4.50, 'L', CURRENT_TIMESTAMP()),
('SKU-HERO-024', 'JOHNS', 'Shampoo 500ML', 'PERS-STORE', 7.00, '0.5L', CURRENT_TIMESTAMP()),
('SKU-HERO-025', 'UNILE', 'Soap Bar 100G', 'PERS-STORE', 2.00, '0.1KG', CURRENT_TIMESTAMP()),
('SKU-HERO-026', 'UNILE', 'Moisturizer 200ML', 'PERS-STORE', 9.50, '0.2L', CURRENT_TIMESTAMP()),
('SKU-HERO-027', 'COLGA', 'Toothpaste 150G', 'PERS-STORE', 3.00, '0.15KG', CURRENT_TIMESTAMP()),
('SKU-HERO-028', 'COLGA', 'Mouthwash 500ML', 'PERS-STORE', 5.00, '0.5L', CURRENT_TIMESTAMP()),
('SKU-HERO-029', 'HENKE', 'Sealant 300ML', 'IND-STORE', 13.00, '0.3L', CURRENT_TIMESTAMP()),
('SKU-HERO-030', 'HENKE', 'Epoxy 500G', 'IND-STORE', 27.00, '0.5KG', CURRENT_TIMESTAMP()),
('SKU-HERO-031', 'ACME', 'Gadget 100G', 'ELEC-STORE', 17.50, '0.1KG', CURRENT_TIMESTAMP()),
('SKU-HERO-032', 'ACME', 'Module 500ML', 'ELEC-STORE', 26.00, '0.5L', CURRENT_TIMESTAMP()),
('SKU-HERO-033', 'NEXUS', 'Valve 250G', 'IND-STORE', 36.00, '0.25KG', CURRENT_TIMESTAMP()),
('SKU-HERO-034', 'NEXUS', 'Bearing 1KG', 'IND-STORE', 55.00, '1KG', CURRENT_TIMESTAMP()),
('SKU-HERO-035', 'PINNA', 'Brake Pad Medium', 'AUTO-STORE', 46.00, 'M', CURRENT_TIMESTAMP()),
('SKU-HERO-036', 'PINNA', 'Spark Plug Small', 'AUTO-STORE', 7.50, 'S', CURRENT_TIMESTAMP()),
('SKU-HERO-037', 'CLORO', 'Bleach 1L', 'CHEM-STORE', 5.80, '1L', CURRENT_TIMESTAMP()),
('SKU-HERO-038', 'CLORO', 'Disinfectant 2L', 'CHEM-STORE', 9.50, '2L', CURRENT_TIMESTAMP()),
('SKU-HERO-039', 'ATLAS', 'Alternator Large', 'AUTO-STORE', 110.00, 'L', CURRENT_TIMESTAMP()),
('SKU-HERO-040', 'ATLAS', 'Starter Medium', 'AUTO-STORE', 85.00, 'M', CURRENT_TIMESTAMP()),
('SKU-HERO-041', 'TITAN', 'Compressor 5KG', 'IND-STORE', 190.00, '5KG', CURRENT_TIMESTAMP()),
('SKU-HERO-042', 'TITAN', 'Turbine Large', 'IND-STORE', 270.00, 'L', CURRENT_TIMESTAMP()),
('SKU-HERO-043', 'SUMMI', 'Stapler Medium', 'OFF-STORE', 10.50, 'M', CURRENT_TIMESTAMP()),
('SKU-HERO-044', 'SUMMI', 'Binder Large', 'OFF-STORE', 7.00, 'L', CURRENT_TIMESTAMP()),
('SKU-HERO-045', 'HORIZ', 'Capacitor 25G', 'ELEC-STORE', 4.80, '25G', CURRENT_TIMESTAMP()),
('SKU-HERO-046', 'HORIZ', 'Transistor 10G', 'ELEC-STORE', 2.80, '10G', CURRENT_TIMESTAMP()),
('SKU-HERO-047', 'NOVA', 'Connector 50G', 'ELEC-STORE', 13.00, '50G', CURRENT_TIMESTAMP()),
('SKU-HERO-048', 'NOVA', 'Cable 5M', 'ELEC-STORE', 8.50, '5M', CURRENT_TIMESTAMP()),
('SKU-HERO-049', 'VERTE', 'Coupling 500G', 'IND-STORE', 33.00, '0.5KG', CURRENT_TIMESTAMP()),
('SKU-HERO-050', 'VERTE', 'Flange 1KG', 'IND-STORE', 43.00, '1KG', CURRENT_TIMESTAMP());

INSERT INTO RELATIONSHIP_DISCOVERY_DB.SRC.ECOMMERCE_PRODUCT (VENDOR_CODE, LISTING_TITLE, VENDOR_NAME, WEB_CATEGORY, SELLER_NAME, SELLING_PRICE, DISPLAY_SIZE, LOAD_DTTM)
VALUES
('ECOM-HERO-021', 'P&G Premium Dishwash 750ml', 'Procter & Gamble', 'Consumer Products', 'MegaSupply Hub', 18.99, '750 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-HERO-022', 'P&G Fabric Softener 2 Liter', 'Procter & Gamble', 'Consumer Products', 'ValueMax Outlet', 24.99, '2 Liters', CURRENT_TIMESTAMP()),
('ECOM-HERO-023', 'J&J Bandage Large - Sterile', 'Johnson & Johnson', 'Health & Wellness', 'PrimeParts Direct', 10.99, 'Large Size', CURRENT_TIMESTAMP()),
('ECOM-HERO-024', 'J&J Daily Shampoo 500ml', 'Johnson & Johnson', 'Beauty & Personal Care', 'QuickShip Warehouse', 14.99, '500 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-HERO-025', 'Unilever Classic Soap Bar 100g', 'Unilever', 'Beauty & Personal Care', 'MegaSupply Hub', 5.49, '100 Grams', CURRENT_TIMESTAMP()),
('ECOM-HERO-026', 'Unilever Moisturizer Cream 200ml', 'Unilever', 'Beauty & Personal Care', 'ValueMax Outlet', 21.99, '200 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-HERO-027', 'Colgate Fresh Toothpaste 150g', 'Colgate', 'Beauty & Personal Care', 'QuickShip Warehouse', 7.49, '150 Grams', CURRENT_TIMESTAMP()),
('ECOM-HERO-028', 'Colgate Mouthwash 500ml - Mint', 'Colgate', 'Beauty & Personal Care', 'PrimeParts Direct', 11.99, '500 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-HERO-029', 'Henkel Pro Sealant 300ml', 'Henkel', 'Industrial & Scientific', 'TechDirect Store', 29.99, '300 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-HERO-030', 'Henkel Epoxy Resin 500g - Heavy Duty', 'Henkel', 'Industrial & Scientific', 'TechDirect Store', 59.99, '500 Grams', CURRENT_TIMESTAMP()),
('ECOM-HERO-031', 'Acme Smart Gadget 100g', 'Acme', 'Electronics & Gadgets', 'TechDirect Store', 38.99, '100 Grams', CURRENT_TIMESTAMP()),
('ECOM-HERO-032', 'Acme Power Module 500ml', 'Acme', 'Electronics & Gadgets', 'Global Manufacturing Co', 57.99, '500 Milliliters', CURRENT_TIMESTAMP()),
('ECOM-HERO-033', 'Nexus Precision Valve 250g', 'Nexus', 'Industrial & Scientific', 'PrimeParts Direct', 79.99, '250 Grams', CURRENT_TIMESTAMP()),
('ECOM-HERO-034', 'Nexus Heavy Bearing 1kg', 'Nexus', 'Industrial & Scientific', 'TechDirect Store', 119.99, '1 Kilogram', CURRENT_TIMESTAMP()),
('ECOM-HERO-035', 'Pinnacle Brake Pad - Medium', 'Pinnacle', 'Automotive Parts', 'QuickShip Warehouse', 98.99, 'Medium Size', CURRENT_TIMESTAMP()),
('ECOM-HERO-036', 'Pinnacle Spark Plug - Small', 'Pinnacle', 'Automotive Parts', 'PrimeParts Direct', 16.99, 'Small Size', CURRENT_TIMESTAMP()),
('ECOM-HERO-037', 'Clorox Original Bleach 1L', 'Clorox', 'Cleaning Supplies', 'MegaSupply Hub', 12.99, '1 Liter', CURRENT_TIMESTAMP()),
('ECOM-HERO-038', 'Clorox Disinfectant Spray 2L', 'Clorox', 'Cleaning Supplies', 'ValueMax Outlet', 19.99, '2 Liters', CURRENT_TIMESTAMP()),
('ECOM-HERO-039', 'Atlas Performance Alternator - Large', 'Atlas', 'Automotive Parts', 'PrimeParts Direct', 229.99, 'Large Size', CURRENT_TIMESTAMP()),
('ECOM-HERO-040', 'Atlas Starter Motor - Medium', 'Atlas', 'Automotive Parts', 'QuickShip Warehouse', 179.99, 'Medium Size', CURRENT_TIMESTAMP()),
('ECOM-HERO-041', 'Titan Industrial Compressor 5kg', 'Titan', 'Industrial & Scientific', 'TechDirect Store', 399.99, '5 Kilograms', CURRENT_TIMESTAMP()),
('ECOM-HERO-042', 'Titan Turbine Large - Commercial', 'Titan', 'Industrial & Scientific', 'Global Manufacturing Co', 569.99, 'Large Size', CURRENT_TIMESTAMP()),
('ECOM-HERO-043', 'Summit Office Stapler - Medium', 'Summit', 'Office & School', 'QuickShip Warehouse', 22.99, 'Medium Size', CURRENT_TIMESTAMP()),
('ECOM-HERO-044', 'Summit Premium Binder - Large', 'Summit', 'Office & School', 'MegaSupply Hub', 15.99, 'Large Size', CURRENT_TIMESTAMP()),
('ECOM-HERO-045', 'Horizon Capacitor 25g - Precision', 'Horizon', 'Electronics & Gadgets', 'TechDirect Store', 11.99, '25 Grams', CURRENT_TIMESTAMP()),
('ECOM-HERO-046', 'Horizon Transistor 10g - Micro', 'Horizon', 'Electronics & Gadgets', 'TechDirect Store', 6.99, '10 Grams', CURRENT_TIMESTAMP()),
('ECOM-HERO-047', 'Nova Connector 50g - Gold Plated', 'Nova', 'Electronics & Gadgets', 'PrimeParts Direct', 28.99, '50 Grams', CURRENT_TIMESTAMP()),
('ECOM-HERO-048', 'Nova Premium Cable 5m', 'Nova', 'Electronics & Gadgets', 'MegaSupply Hub', 19.99, '5 Meters', CURRENT_TIMESTAMP()),
('ECOM-HERO-049', 'Vertex Industrial Coupling 500g', 'Vertex', 'Industrial & Scientific', 'TechDirect Store', 72.99, '500 Grams', CURRENT_TIMESTAMP()),
('ECOM-HERO-050', 'Vertex Heavy Flange 1kg', 'Vertex', 'Industrial & Scientific', 'PrimeParts Direct', 92.99, '1 Kilogram', CURRENT_TIMESTAMP());
