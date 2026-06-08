/*======================================================================
  PROMPT 017 – STREAMLIT DASHBOARD IMPLEMENTATION

  Purpose:
  Generate a production-quality Streamlit dashboard for the
  Relationship Discovery Framework.

  The dashboard must provide:

  - Business Storytelling
  - Relationship Discovery Transparency
  - Relationship Cataloging Insights
  - Data Quality Visibility
  - Golden Record Visibility
  - Metadata Governance Visibility
  - Security Governance Visibility
  - Architecture Transparency

======================================================================*/

======================================================================
OBJECTIVE
======================================================================

Generate a production-quality Streamlit dashboard for the
Relationship Discovery Framework.

The dashboard shall provide a complete business,
technical and governance view of the platform.

The dashboard shall support:

- Hackathon Demonstrations
- Executive Walkthroughs
- Architecture Reviews
- MDM Capability Assessments

The dashboard must clearly demonstrate:

- Relationship Discovery
- Relationship Cataloging
- Data Quality
- Golden Record Construction
- Metadata Governance
- Security Governance
- Auditability
- Architecture Transparency

======================================================================
OUTPUT
======================================================================

Generate:

app/streamlit_app.py

Generate only the complete executable Streamlit application.

======================================================================
GOVERNANCE INPUTS
======================================================================

Read and comply with:

- governance/001_MASTER_CONSTITUTION.md
- governance/002_APPROVED_DECISIONS_REGISTER.md
- governance/003_PROMPT_OS.md
- governance/004_PROJECT_CONTEXT.md
- governance/005_METADATA_DESIGN.md
- governance/006_SECURITY_ARCHITECTURE.md

All approved decisions are mandatory.

======================================================================
BUSINESS CONTEXT
======================================================================

The platform resolves fragmented product records across:

- ERP_PRODUCT
- SUPPLIER_PRODUCT
- INVENTORY_PRODUCT
- ECOMMERCE_PRODUCT

into governed golden records.

The dashboard is the primary business-facing interface
for the platform.

The dashboard must explain:

Source Records
↓
Relationship Discovery
↓
Relationship Cataloging
↓
Mastering
↓
Governance
↓
Security
↓
Golden Records

======================================================================
DATABASE
======================================================================

Database:

RELATIONSHIP_DISCOVERY_DB

======================================================================
SOURCE TABLES
======================================================================

SOURCE_SUPERSET

RELATIONSHIP_DISCOVERY_DB.INTM.SOURCE_SUPERSET

Purpose:

Canonical harmonized source layer.

---------------------------------------------------------------------

RELATIONSHIP_CANDIDATES

RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CANDIDATES

Purpose:

Stores all discovered candidate matches.

---------------------------------------------------------------------

RELATIONSHIP_CATALOG

RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CATALOG

Purpose:

Stores best-match relationships.

---------------------------------------------------------------------

DQ_RECORD_SUMMARY

RELATIONSHIP_DISCOVERY_DB.INTM.DQ_RECORD_SUMMARY

Purpose:

Stores record-level DQ scores.

---------------------------------------------------------------------

INTM_PRODUCT_MASTER

RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER

Purpose:

Stores versioned master history.

---------------------------------------------------------------------

PRODUCT_MASTER

RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER

Purpose:

Stores active golden records.

---------------------------------------------------------------------

ACTION_LOG

RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG

Purpose:

Stores CREATE and UPDATE actions.

---------------------------------------------------------------------

Metadata Tables

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_DQ_RULES

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP

RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_MAPPING

======================================================================
TECHNICAL STANDARDS
======================================================================

Use:

from snowflake.snowpark.context import get_active_session

session = get_active_session()

Use:

@st.cache_data(ttl=600)

for all query helper functions.

All queries must use fully qualified table names.

Use Snowflake Streamlit compatible code only.

======================================================================
DESIGN REQUIREMENTS
======================================================================

Implement:

- Gradient Metric Cards
- Styled Tab Navigation
- Pill Style Tabs
- Responsive Layout
- Modern Typography
- Business Callout Boxes
- Consistent Branding

Color Palette:

Indigo  #4f46e5

Violet  #7c3aed

Emerald #10b981

Amber   #f59e0b

Rose    #f43f5e

Sky     #0ea5e9

======================================================================
VISUALIZATION STANDARDS
======================================================================

Use:

- Altair
- Streamlit Native Components

Do not use:

- Plotly
- Matplotlib
- Seaborn

======================================================================
TAB 1 – THE STORY
======================================================================

Purpose:

Executive narrative.

Must include:

Problem Statement

Narrative callout.

---------------------------------------------------------------------

Relationship Discovery Pipeline

Display:

42,450 Source Records

↓

21,797,578 Candidate Pairs

↓

30,000 Cataloged Relationships

↓

5,567 Golden Records

↓

86.9% Deduplication

---------------------------------------------------------------------

Consolidation Funnel

Altair visualization.

---------------------------------------------------------------------

Source System Distribution

ERP         10,250

SUPPLIER    10,800

INVENTORY   10,450

ECOMMERCE   10,950

---------------------------------------------------------------------

Differentiators

- Multi-Tier Matching
- DQ-Weighted Discovery
- Metadata-Driven Governance

---------------------------------------------------------------------

Executive KPI Row

- Consolidation Ratio
- Deduplication %
- Precision Filter %
- DQ Pass Rate
- Versions Tracked

======================================================================
TAB 2 – LIVE EXPLORER
======================================================================

Purpose:

Primary hackathon demonstration tab.

Implement:

st.radio(horizontal=True)

Modes:

1. Before / After – Source vs Golden

2. Entity Deep Dive

3. Relationship Lookup

---------------------------------------------------------------------

Before / After

Capabilities:

- Select Golden Record
- Retrieve Linked Source Records
- Display Raw Source Differences
- Display Golden Record
- Highlight Survivorship Decisions
- Highlight Attribute Conflicts

---------------------------------------------------------------------

Entity Deep Dive

Capabilities:

- Select Entity
- Show Version Timeline
- Show Version History
- Show Active Version
- Show Processing Lineage

---------------------------------------------------------------------

Relationship Lookup

Capabilities:

- Select Source System
- Select Source Record
- Show Relationships
- Show Match Scores
- Show Confidence
- Show DQ Weighted Scores

======================================================================
TAB 3 – DISCOVERY ENGINE
======================================================================

Purpose:

Demonstrate relationship discovery innovation.

Must include:

- Candidate Volume
- Catalog Volume
- Reduction %
- Average DQ Score

---------------------------------------------------------------------

Match Tier Analysis

T0 – Exact Match

T1 – Fuzzy Match

T2 – Prefix Match

---------------------------------------------------------------------

Relationship Density Heatmap

Cross-system relationship counts.

---------------------------------------------------------------------

Selectivity Analysis

Candidates

vs

Cataloged

for each match tier.

======================================================================
TAB 4 – DATA QUALITY
======================================================================

Purpose:

Demonstrate DQ-first design.

Must include:

- Records Assessed
- Average Score
- Pass Rate
- Warning Count

---------------------------------------------------------------------

DQ Status By Source

PASS vs WARNING

---------------------------------------------------------------------

DQ Score Distribution

Histogram

---------------------------------------------------------------------

DQ Rules

Read from:

MD_ATTRIBUTE_DQ_RULES

---------------------------------------------------------------------

DQ Narrative

DQ Score
↓
DQ Weighted Score
↓
Relationship Discovery
↓
Survivorship

======================================================================
TAB 5 – GOLDEN MASTER
======================================================================

Purpose:

Demonstrate mastering outcomes.

Must include:

- Golden Records
- Product Families
- Product Groups
- Active Records
- Review Records

---------------------------------------------------------------------

Product Family Distribution

---------------------------------------------------------------------

Source Contribution Analysis

---------------------------------------------------------------------

Survivorship Matrix

Read from:

MD_ATTRIBUTE_SURVIVORSHIP

Display:

Attribute × Source × Priority

---------------------------------------------------------------------

Processing Audit Trail

Display metrics for:

P10_MASTER_CREATION

P12_PRODUCT_FAMILY

P13_PRODUCT_GROUP

P14_PRODUCT_STATUS

======================================================================
TAB 6 – ARCHITECTURE
======================================================================

Purpose:

Demonstrate transparency.

Must include:

P1–P16 architecture.

---------------------------------------------------------------------

Architecture Diagram

Display:

P1
↓
P2
↓
...
↓
P16

---------------------------------------------------------------------

Architecture Principles

- Separation Of Concerns
- Auditability
- Metadata Driven
- Security First

---------------------------------------------------------------------

Technology Stack

- Snowflake
- Snowpark
- Streamlit
- Altair
- RBAC
- Dynamic Masking

======================================================================
SECURITY REQUIREMENTS
======================================================================

Display:

RBAC

Roles:

- MDM_ADMIN
- MDM_DATA_STEWARD
- MDM_BUSINESS_USER
- MDM_AUDITOR

---------------------------------------------------------------------

Dynamic Masking

Protected Attributes:

- SALE_PRICE
- SOURCE_EXECUTION_REFERENCE
- ACTION_SOURCE

---------------------------------------------------------------------

Masked Values

Handle:

***MASKED***

gracefully without errors.

======================================================================
HARDCODED BUSINESS METRICS
======================================================================

Use where appropriate:

42,450 Source Records

21,797,578 Candidates

30,000 Cataloged Relationships

5,567 Golden Records

7.6:1 Consolidation Ratio

86.9% Deduplication

99.86% Precision Filter

98.9% DQ Pass Rate

22,268 Actions

100% Success Rate

4 RBAC Roles

3 Masking Policies

======================================================================
GUARDRAILS
======================================================================

Do not:

- Use Plotly
- Use Matplotlib
- Use Seaborn
- Use Custom JavaScript
- Expose RBAC SQL
- Expose Masking Policy SQL

Use:

- Streamlit
- Altair
- Snowpark

only.

======================================================================
SUCCESS CRITERIA
======================================================================

The dashboard must clearly demonstrate:

Relationship Discovery ✓

Relationship Cataloging ✓

Data Quality ✓

Golden Record Construction ✓

Metadata Governance ✓

Security Governance ✓

Auditability ✓

Architecture Transparency ✓

The dashboard must be suitable for:

- Hackathon Demonstrations
- Executive Showcases
- Architecture Reviews
- MDM Capability Assessments

Generate complete executable Streamlit code.

======================================================================
END OF PROMPT
======================================================================
