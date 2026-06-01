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
