# METADATA DESIGN

Version: 1.0

Status: APPROVED

---

# 1. Objective

Define the metadata entities required to support Data Quality (DQ) and Survivorship within the Relationship Discovery Framework.

The objective is to provide sufficient metadata to support the Product MDM demonstration without introducing unnecessary complexity.

---

# 2. Scope

Metadata is required for:

* Data Quality Assessment
* Attribute Survivorship

Metadata is not required for:

* Relationship Discovery Transformations
* Source Harmonization
* Workflow Management
* User Management
* Runtime Configuration

These capabilities are intentionally hardcoded for the Product MDM demonstration.

---

# 3. Metadata Entity: MD_ATTRIBUTE_DQ_RULES

## Purpose

Define DQ requirements for canonical product attributes.

This metadata drives DQ execution at SOURCE_SUPERSET.

## Business Usage

Determine:

* Critical Attributes
* Mandatory Attributes
* DQ Validation Requirements

## Example Attributes

* ATTRIBUTE_NAME
* IS_CRITICAL
* IS_MANDATORY
* DQ_RULE
* ACTIVE_FLAG

## Example Records

BRAND

* IS_CRITICAL = Y
* IS_MANDATORY = Y

PRODUCT_NAME

* IS_CRITICAL = Y
* IS_MANDATORY = Y

CATEGORY

* IS_CRITICAL = N
* IS_MANDATORY = N

---

# 4. Metadata Entity: MD_ATTRIBUTE_SURVIVORSHIP

## Purpose

Define source priority by canonical attribute.

This metadata drives Golden Record attribute selection.

## Business Usage

Determine which source value should be selected when multiple source values exist.

## Example Attributes

* ATTRIBUTE_NAME
* SOURCE_SYSTEM
* PRIORITY
* ACTIVE_FLAG

## Example Records

BRAND

ERP_PRODUCT

Priority = 1

BRAND

SUPPLIER_PRODUCT

Priority = 2

BRAND

ECOMMERCE_PRODUCT

Priority = 3

---

# 5. Design Principles

## Principle 1

DQ must be metadata-driven.

## Principle 2

Survivorship must be metadata-driven.

## Principle 3

Metadata changes must not require code changes.

## Principle 4

Metadata must remain business-readable.

---

# 6. Out of Scope

The following are intentionally not metadata-driven:

## Transformations

Approved transformations are hardcoded:

* Direct Match
* Prefix/Suffix Removal
* Left-N Character Match

## Source Harmonization

Source-to-SOURCE_SUPERSET mappings are hardcoded.

## Relationship Discovery Logic

Relationship Discovery logic is hardcoded.

---

# 7. Architecture Placement

SOURCE_TABLES

↓

SOURCE_SUPERSET

↓

MD_ATTRIBUTE_DQ_RULES

↓

DQ

↓

RELATIONSHIP_DISCOVERY

↓

RELATIONSHIP_CATALOG

↓

MD_ATTRIBUTE_SURVIVORSHIP

↓

CREATE_PRODUCT_BR

↓

ACTION_LOG

↓

DAL

↓

INTM_PRODUCT

---

# 8. Approval Status

Approved
