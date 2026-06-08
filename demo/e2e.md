# 5-MINUTE DEMO SCRIPT – GOVERNED AI MDM PLATFORM

## OPENING (10 SECONDS)

Today I'll demonstrate a Governed AI-Powered Relationship Discovery and Master Data Management Platform.

Rather than simply generating code with AI, we governed the AI itself, used it to generate architecture-compliant artifacts, and then executed those artifacts to build a secure, auditable and metadata-driven MDM solution.

The demo is split into four phases:

1. AI Governance
2. Relationship Discovery & Cataloging
3. Mastering Engine & Execution
4. Governance, Security & Business Value

---

## PHASE 1 – AI GOVERNANCE (45 SECONDS)

Open Governance Folder

Show:

001_MASTER_CONSTITUTION

002_APPROVED_DECISIONS_REGISTER

003_PROMPT_OS

004_PROJECT_CONTEXT

005_METADATA_DESIGN

006_SECURITY_ARCHITECTURE

Say:

Most teams use AI to generate code.

We governed AI before allowing it to generate anything.

Every prompt must comply with architecture decisions, metadata standards, security standards and prompt governance.

This prevents architectural drift and ensures consistent, repeatable outputs.

Open ADR

Show:

* Relationship Candidate First
* Relationship Catalog Driven Matching
* BR → DAL Pattern
* Versioning
* Metadata Driven Governance
* Security By Design

Say:

Every generated artifact automatically inherits these decisions.

The LLM cannot generate implementations that violate approved architecture.

This is AI Governance.

---

## PHASE 2 – RELATIONSHIP DISCOVERY & CATALOGING (1 MINUTE)

Go To Dashboard

Open:

Relationship Discovery

Say:

Before creating a master record, we must first determine which records belong together across ERP, Supplier, Inventory and Ecommerce systems.

Show Discovery Funnel

Point to:

* Candidates Evaluated
* Cataloged (Best Match)
* Precision Filter
* Catalog Ratio

Say:

Our engine evaluates relationship candidates across all source systems and filters them into a trusted catalog.

Show Match Type Distribution

Point to:

* T0
* T1
* T2

Say:

T0 represents exact matches.

T1 represents fuzzy matches.

T2 represents similarity and prefix-based matches.

Show Cross-System Connectivity Heatmap

Say:

This shows how products connect across different source systems.

The result is a trusted relationship catalog that becomes the foundation of mastering.

Run SQL:

SELECT
MATCH_TYPE,
MATCH_CONFIDENCE,
COUNT(*)
FROM RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CATALOG
GROUP BY 1,2
ORDER BY 1,2;

Say:

Every relationship is scored, classified and cataloged before any mastering occurs.

---

## PHASE 3 – MASTERING ENGINE & EXECUTION (1 MINUTE 30 SECONDS)

Go To Architecture Tab

Show:

P10
P11
P12
P13
P14
P15
P16

Say:

Once relationships are cataloged, mastering begins.

Instead of generating one large application, we generated governed and reusable artifacts.

Highlight:

P10 – Master Creation

P11 – DAL

P12 – Product Family

P13 – Product Group

P14 – Product Status

P15 – Publish

P16 – Security

Say:

Business Rules never update records directly.

Business Rules generate actions.

The DAL materializes those actions into the master data layer.

Run SQL:

SELECT
ACTION_TYPE,
ACTION_SOURCE,
ACTION_STATUS,
COUNT(*) CNT
FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
GROUP BY 1,2,3
ORDER BY 1,2;

Say:

Every business rule creates auditable actions.

This provides complete transparency and control over execution.

Go To:

MDM Processing

Show:

* Phase 1 – Entities Created
* Phase 2 – Families Derived
* Phase 3 – Groups Derived
* Phase 4 – Statuses Derived

Say:

Every transformation is executed through the DAL while preserving complete history.

Go To:

Lineage & Audit

Select one ENTITY_KEY

Run SQL:

SELECT
ENTITY_KEY,
VERSION_NO,
ACTION_SOURCE,
ACTIVE_FLAG
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ENTITY_KEY = '<ENTITY_KEY>'
ORDER BY VERSION_NO;

Say:

This demonstrates complete lineage.

Every version can be traced back to the exact business rule that created it.

Example:

Version 1 → P10_MASTER_CREATION

Version 2 → P12_PRODUCT_FAMILY

Version 3 → P13_PRODUCT_GROUP

Version 4 → P14_PRODUCT_STATUS

This gives us full auditability and explainability.

---

## PHASE 4 – GOVERNANCE, SECURITY & BUSINESS VALUE (1 MINUTE 20 SECONDS)

Go To:

Metadata & Governance

Say:

Governance is externalized into metadata rather than embedded in code.

Show DQ Rules

Say:

Data Quality is driven by metadata-defined rules.

Show Survivorship Rules

Say:

When multiple systems provide the same attribute, metadata determines which source wins.

Show Attribute Mapping

Say:

Each source system maps into a canonical product model.

Show Security Architecture

Say:

We implemented security using Role-Based Access Control and Dynamic Data Masking.

Run SQL:

USE ROLE MDM_ADMIN;

SELECT
SALE_PRICE,
ACTION_SOURCE
FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER
LIMIT 5;

Say:

Administrators can view commercial and lineage information.

Run SQL:

USE ROLE MDM_BUSINESS_USER;

SELECT
SALE_PRICE,
ACTION_SOURCE
FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER
LIMIT 5;

Say:

Business users can consume mastered data while sensitive information remains protected.

Go To:

Executive Summary

Show:

* Total Products
* Product Families
* Product Groups
* Product Statuses
* Security Posture

Say:

This is the final governed golden record layer consumed by the business.

---

## CLOSING (15 SECONDS)

We did not simply build an MDM platform.

We built a governed AI engineering framework.

Governance controls the AI.

The AI generates architecture-compliant artifacts.

Those artifacts create secure, metadata-driven, versioned and fully auditable master data products.

The result is a platform that delivers relationship discovery, mastering, governance, security and complete business traceability.

---

## SQL CHEAT SHEET

SELECT CURRENT_ROLE();

SELECT
MATCH_TYPE,
MATCH_CONFIDENCE,
COUNT(*)
FROM RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CATALOG
GROUP BY 1,2
ORDER BY 1,2;

SELECT
ACTION_TYPE,
ACTION_SOURCE,
ACTION_STATUS,
COUNT(*) CNT
FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
GROUP BY 1,2,3
ORDER BY 1,2;

SELECT
ENTITY_KEY,
VERSION_NO,
ACTION_SOURCE,
ACTIVE_FLAG
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ENTITY_KEY = '<ENTITY_KEY>'
ORDER BY VERSION_NO;

USE ROLE MDM_ADMIN;

SELECT
SALE_PRICE,
ACTION_SOURCE
FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER
LIMIT 5;

USE ROLE MDM_BUSINESS_USER;

SELECT
SALE_PRICE,
ACTION_SOURCE
FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER
LIMIT 5;
