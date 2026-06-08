# 5-MINUTE DEMO SCRIPT

## Opening Statement (10 seconds)

Today I will demonstrate how we built a governed, metadata-driven MDM platform using AI.

Rather than simply generating code with an LLM, we first governed how the LLM could think, design and generate artifacts.

The demo is split into four phases:

1. AI Governance
2. Prompt → Artifact Architecture
3. Business Rule & DAL Execution
4. Dashboards & Business Value

---

# PHASE 1 – AI GOVERNANCE (1 Minute 30 Seconds)

## Screen

Open governance folder.

Show:

* 001_MASTER_CONSTITUTION
* 002_APPROVED_DECISIONS_REGISTER
* 003_PROMPT_OS
* 004_PROJECT_CONTEXT
* 005_METADATA_DESIGN
* 006_SECURITY_ARCHITECTURE

## Talk Track

Most teams use AI to generate code.

We governed AI before allowing it to generate code.

Every generated artifact must comply with:

* Platform Governance
* Architecture Decisions
* Prompt Standards
* Metadata Rules
* Security Standards

This prevents architectural drift and ensures consistent implementation.

---

## Show ADR

Open:

002_APPROVED_DECISIONS_REGISTER

Highlight:

* BR → DAL Pattern
* One Active Record Per Entity
* Soft Deletes
* Versioning
* Metadata Driven Governance
* RBAC + Dynamic Masking

## Talk Track

Every future prompt inherits these decisions automatically.

This means the LLM cannot generate implementations that violate approved architecture.

This is AI Governance.

---

# PHASE 2 – PROMPT → ARTIFACT ARCHITECTURE (1 Minute)

## Screen

Open prompts folder.

Show:

* P10_MASTER_CREATION
* P11_DAL
* P12_PRODUCT_FAMILY
* P13_PRODUCT_GROUP
* P14_PRODUCT_STATUS
* P15_PUBLISH_MASTER
* P16_SECURITY_IMPLEMENTATION

## Talk Track

Instead of generating a monolithic application, we generated independent governed assets.

Pattern:

Prompt
↓
Governance
↓
SQL Artifact

Each prompt has a single responsibility.

Each artifact remains modular, testable and reusable.

Example:

P13_PRODUCT_GROUP

Prompt
↓
013_DERIVE_PRODUCT_GROUP.SQL

This creates controlled, repeatable engineering.

---

# PHASE 3 – BUSINESS RULE & DAL EXECUTION (1 Minute 15 Seconds)

## Screen

Show Architecture Diagram

ERP
SUPPLIER
INVENTORY
ECOMMERCE

↓

P10_MASTER_CREATION

↓

ACTION_LOG

↓

P11_DAL

↓

INTM_PRODUCT_MASTER

↓

P12_PRODUCT_FAMILY

↓

P13_PRODUCT_GROUP

↓

P14_PRODUCT_STATUS

↓

P15_PUBLISH_MASTER

↓

FINAL.PRODUCT_MASTER

↓

P16_SECURITY

↓

Dashboard

---

## Talk Track

Business Rules never update records directly.

Business Rules generate actions.

DAL executes actions.

Every change becomes versioned and auditable.

---

## SQL 1 – Show Actions Generated

```sql
SELECT
    ACTION_TYPE,
    ACTION_SOURCE,
    ACTION_STATUS,
    COUNT(*) CNT
FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG
GROUP BY 1,2,3
ORDER BY 1,2;
```

## Talk Track

Each Business Rule generates actions instead of directly modifying records.

This creates a controlled execution model.

---

## SQL 2 – Show Versioning

```sql
SELECT
    ENTITY_KEY,
    VERSION_NO,
    ACTION_SOURCE,
    ACTIVE_FLAG
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
ORDER BY ENTITY_KEY, VERSION_NO;
```

## Talk Track

Every update creates a new version.

History is preserved while maintaining one active record.

---

## SQL 3 – Show Lineage (Most Important SQL)

Choose one ENTITY_KEY.

```sql
SELECT
    ENTITY_KEY,
    VERSION_NO,
    ACTION_SOURCE,
    DERIVED_PRODUCT_FAMILY,
    DERIVED_PRODUCT_GROUP,
    DERIVED_PRODUCT_STATUS
FROM RELATIONSHIP_DISCOVERY_DB.INTM.INTM_PRODUCT_MASTER
WHERE ENTITY_KEY = '<ENTITY_KEY>'
ORDER BY VERSION_NO;
```

## Talk Track

This demonstrates complete lineage.

We can trace exactly which business rule created every version.

Example:

Version 1 → P10_MASTER_CREATION

Version 2 → P12_PRODUCT_FAMILY

Version 3 → P13_PRODUCT_GROUP

Version 4 → P14_PRODUCT_STATUS

---

# PHASE 4 – DASHBOARDS & BUSINESS VALUE (1 Minute 15 Seconds)

Do NOT show every tab.

Show only three tabs.

---

## TAB 1 – Metadata & Governance

### Talk Track

Governance is externalized into metadata.

Show:

* DQ Rules
* Survivorship Rules
* Attribute Mapping
* Security Controls

Explain:

Mappings determine how source attributes become canonical attributes.

Survivorship rules determine source priorities.

DQ rules define quality expectations.

Security rules govern platform access.

Spend ~20 seconds.

---

## TAB 2 – Lineage & Audit

Select one ENTITY_KEY.

Show:

Version 1 → P10_MASTER_CREATION

Version 2 → P12_PRODUCT_FAMILY

Version 3 → P13_PRODUCT_GROUP

Version 4 → P14_PRODUCT_STATUS

## Talk Track

This demonstrates complete auditability.

Every version remains traceable.

Every transformation remains explainable.

Spend ~30 seconds.

---

## TAB 3 – Executive Summary

Show:

* Total Products
* Product Families
* Product Groups
* Product Statuses
* Security Overview

## Talk Track

This is the final mastered product domain.

All records have passed through governance, survivorship, derivation and security controls.

Spend ~20 seconds.

---

# BONUS – SECURITY (Only If Asked)

## SQL – Show Roles

```sql
SHOW ROLES LIKE 'MDM%';
```

## SQL – Show Masking Policies

```sql
SHOW MASKING POLICIES;
```

## SQL – Show Policy Assignments

```sql
SELECT *
FROM TABLE(
  RELATIONSHIP_DISCOVERY_DB.INFORMATION_SCHEMA.POLICY_REFERENCES(
    POLICY_NAME => 'MASK_ACTION_SOURCE'
  )
);
```

## Talk Track

Security is implemented through:

* RBAC
* Dynamic Data Masking

Security is governed using the same framework as metadata and business rules.

---

# CLOSING STATEMENT (15 Seconds)

We did not simply build an MDM platform.

We built a governed AI engineering framework that converts architecture decisions, metadata and prompts into auditable enterprise data products.

The result is:

* Governed AI Development
* Metadata Driven MDM
* Versioned Lineage
* Security By Design
* Fully Auditable Master Data

Thank you.
