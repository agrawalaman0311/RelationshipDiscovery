# 006_SECURITY_ARCHITECTURE.md

## Purpose

Define the security architecture for the MDM platform.

This document governs:

* Role Based Access Control (RBAC)
* Dynamic Data Masking
* Security Responsibilities
* Access Model

Security requirements defined here are mandatory.

---

# Security Principles

The platform shall implement:

1. Least Privilege Access
2. Role Based Access Control
3. Metadata Driven Governance
4. Auditability
5. Separation Of Duties

---

# Security Architecture

Governance
↓

Metadata
↓

Prompt Governance
↓

Generated Assets
↓

Security Layer

```
RBAC
Dynamic Masking

    ↓
```

Published Master Data

---

# Supported Security Controls

## RBAC

The platform shall use Snowflake Role Based Access Control.

### MDM_ADMIN

Permissions:

* Full Database Access
* Metadata Maintenance
* Rule Maintenance
* Dashboard Access
* Security Administration

---

### MDM_DATA_STEWARD

Permissions:

* Read Metadata
* Read Master Data
* Read Action Log
* Read Audit History

No DDL permissions.

---

### MDM_BUSINESS_USER

Permissions:

* Read FINAL.PRODUCT_MASTER

No metadata access.

No action log access.

---

### MDM_AUDITOR

Permissions:

* Read Action Log
* Read Version History
* Read Metadata

No modification permissions.

---

# Dynamic Data Masking

The platform shall implement masking policies.

Masking shall be role-aware.

Example Protected Attributes:

* SALE_PRICE
* SOURCE_EXECUTION_REFERENCE

---

# Masking Behaviour

MDM_ADMIN

Visible

---

MDM_DATA_STEWARD

Visible

---

MDM_AUDITOR

Masked

---

MDM_BUSINESS_USER

Masked

---

# Row Level Security

Not Implemented.

Reason:

Current product master does not contain:

* Business Unit
* Region
* Country
* Department

required for meaningful row access policies.

---

# Security Scope

Included

* RBAC
* Dynamic Masking

Excluded

* Row Access Policies
* ABAC
* SSO
* OAuth
* MFA

---

# Success Criteria

The platform shall:

* Restrict access through roles
* Protect sensitive attributes
* Support auditability
* Demonstrate enterprise security controls
* Remain simple enough for hackathon implementation
