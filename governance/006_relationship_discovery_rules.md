# 006_RELATIONSHIP_DISCOVERY_RULES

Version: 1.0

Status: APPROVED

---

# 1. Objective

Define the approved relationship discovery patterns used by the Relationship Discovery Framework.

These patterns are used by:

* Test Data Generation
* Relationship Discovery Engine
* Relationship Catalog
* Business Rules
* Reporting

All future implementations must comply with these definitions.

---

# 2. Relationship Types

| Relationship Type   | Code | Confidence |
| ------------------- | ---- | ---------- |
| Exact Match         | T0   | High       |
| Prefix/Suffix Match | T1   | Medium     |
| Left-N Match        | T2   | Medium-Low |
| Rejected Candidate  | T3   | None       |

---

# 3. T0 - Exact Match

## Definition

Two values are considered a T0 relationship when the normalized values are identical.

## Rule

VALUE_A = VALUE_B

after approved standardization.

## Examples

Brand

Acme

Acme

Product Name

Widget 500ML

Widget 500ML

Size

500ML

500ML

## Expected Outcome

Relationship Created

## Confidence

High

---

# 4. T1 - Prefix/Suffix Match

## Definition

One value contains the other value after standardization.

## Rule

VALUE_A contains VALUE_B

or

VALUE_B contains VALUE_A

## Examples

Acme Widget

Premium Acme Widget

Acme Widget 500ML

Acme Widget XL

Acme Official

Acme

## Expected Outcome

Relationship Candidate

## Confidence

Medium

---

# 5. T2 - Left-N Match

## Definition

The first N characters of two values match.

N is configurable.

Default N = 3.

## Rule

LEFT(VALUE_A, N) = LEFT(VALUE_B, N)

## Examples

ACME

ACM

ACME_CORP

NEXUS

NEX

PINNACLE

PIN

## Expected Outcome

Relationship Candidate

## Confidence

Medium-Low

---

# 6. T3 - Rejected Candidate

## Definition

Records appear similar but fail business validation rules.

## Rule

Potential relationship exists but required business criteria are not met.

## Examples

Brand

Acme

Nexus

Product Name

Widget 500ML

Widget 500ML

Same Product Name

Different Brand

Result:

Rejected

---

# 7. Test Data Distribution

The approved synthetic dataset shall contain:

| Relationship Type | Target Distribution |
| ----------------- | ------------------- |
| T0                | 40%                 |
| T1                | 30%                 |
| T2                | 20%                 |
| T3                | 10%                 |

The distribution must be intentional and deterministic.

Random occurrence is not acceptable.

---

# 8. Shared Product Population Requirement

A single PRODUCT_SEED population shall be created.

All source systems must be derived from PRODUCT_SEED.

Relationship patterns shall be applied during source derivation.

Independent source generation is not permitted.

---

# 9. Approved Usage

These relationship types may be used by:

* SOURCE_TEST_DATA
* RELATIONSHIP_DISCOVERY
* RELATIONSHIP_CATALOG
* CREATE_BR
* REPORTING

---

# 10. Approval Status

Approved

# ENTITY RESOLUTION GOVERNANCE

## Purpose

Relationship Discovery identifies related records.

Entity Resolution identifies real-world business entities.

These are separate processes.

A relationship does not represent a business entity.

Multiple relationship records may belong to the same business entity.

---

## Duplicate Source Records

The platform must assume duplicate product records may exist:

* Within the same source system
* Across different source systems

Entity Resolution must consolidate duplicate records representing the same real-world product.

---

## Graph-Based Entity Resolution

Entity Resolution must treat:

RELATIONSHIP_CATALOG

as a relationship graph.

Definitions:

Node = Source Record

Edge = Relationship

Business Entity = Connected Component

All records belonging to the same connected component must be assigned to the same ENTITY_KEY.

---

## Lineage Preservation

Entity Resolution must preserve complete lineage.

The platform must not discard source records during Entity Resolution.

Multiple records from the same source system may belong to the same business entity.

---

## Survivorship Separation

Entity Resolution must not perform:

* Survivorship
* Golden Record Creation
* Attribute Selection
* Master Record Selection

These activities occur in later Business Rules.

Entity Resolution is responsible only for grouping records into entities.

---

## DQ Participation

DQ metrics must be preserved during Entity Resolution.

DQ scores may be used in later survivorship and mastering processes.

Entity Resolution must not eliminate records solely because of lower DQ scores.

---

## Source Record Ownership Rule

Each source record must belong to exactly one ENTITY_KEY.

A source record must never belong to multiple entities.

This rule is mandatory and must be validated during Entity Resolution.

---

## Entity Resolution Output Model

ENTITY_RESOLUTION is a lineage-preserving structure.

The table must contain:

* ENTITY_KEY
* SOURCE_SYSTEM
* SOURCE_RECORD_ID
* RECORD_DQ_SCORE

The table must not collapse multiple source records into a single source-specific column structure.

Lineage must remain fully traceable for all participating records.

---

## Mastering Separation

Entity Resolution is not responsible for:

* Canonical attribute selection
* Survivorship
* Action generation
* Master record creation

These activities will occur in later Business Rules and DAL processing.

ENTITY_RESOLUTION is responsible only for assigning source records to business entities.
