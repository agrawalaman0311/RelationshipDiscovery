This solution is a Relationship Discovery Framework.

Product MDM is the demonstration use case.

Architecture:

SOURCE_TABLES
↓
SOURCE_SUPERSET
↓
DQ
↓
RELATIONSHIP_DISCOVERY
↓
RELATIONSHIP_CATALOG
↓
CREATE_BR
↓
ACTION_LOG
↓
DAL
↓
INTM_PRODUCT
↓
ENRICHMENT
↓
FINAL_PRODUCT

Golden Key:
BRAND|PRODUCT_NAME|SIZE

Processing Pattern:
BR → ACTION_LOG → DAL → INTM

Source Systems:
ERP
SUPPLIER
INVENTORY
ECOMMERCE

Canonical Attributes:
BRAND
PRODUCT_NAME
CATEGORY
MANUFACTURER
SALE_PRICE
SIZE

Transformation Library:
Direct Match
Prefix/Suffix Removal
Left-N Match

One Prompt = One Artifact
