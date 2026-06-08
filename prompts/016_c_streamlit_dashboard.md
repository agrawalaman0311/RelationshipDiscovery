---

Security Architecture

Purpose

Demonstrate enterprise-grade security controls implemented within the Relationship Discovery Framework.

Requirements

1. Display RBAC Overview.

Roles:

* MDM_ADMIN
* MDM_DATA_STEWARD
* MDM_AUDITOR
* MDM_BUSINESS_USER

Display role responsibilities.

MDM_ADMIN

* Full platform access
* Metadata maintenance
* Security administration
* Master record maintenance

MDM_DATA_STEWARD

* Data quality review
* Relationship review
* Master data review

MDM_AUDITOR

* Audit access
* Lineage visibility
* Governance reporting

MDM_BUSINESS_USER

* Read-only business consumption
* Masked sensitive attributes

2. Display Dynamic Masking Overview.

Protected Attributes:

* SALE_PRICE
* SOURCE_EXECUTION_REFERENCE
* ACTION_SOURCE

Show masking behavior by role.

3. Display Security Metrics.

* RBAC Roles
* Masking Policies
* Protected Attributes
* Secured Tables

4. Display Security Narrative.

Visualize:

Role Assignment
↓
Access Control
↓
Data Protection
↓
Governed Consumption

5. Display Security Coverage.

Show:

* Metadata Layer
* Intermediate Layer
* Final Layer
* Dashboard Layer

6. Display Governance Alignment.

Show relationship between:

* Governance Controls
* Security Controls
* Business Controls

7. Do not expose:

* GRANT statements
* Role hierarchy SQL
* Masking policy SQL
* Security implementation SQL

---

Critical Constraints

The dashboard must:

* Run natively inside Snowflake Streamlit
* Use Snowpark for all database access
* Use fully-qualified table names
* Use cached query functions
* Use Altair visualizations only
* Support responsive layouts
* Support business and technical users

The dashboard must not:

* Use Plotly
* Use Matplotlib
* Use Seaborn
* Use custom JavaScript
* Use external APIs
* Use unsupported Snowflake packages

The dashboard must not expose:

* Internal SQL artifacts
* Governance document contents
* Security implementation SQL
* Sensitive masked values

The dashboard must gracefully handle:

* Empty datasets
* Missing values
* Masked attributes
* No relationship results
* No lineage results

---

Key Metrics To Reference

Use the following platform metrics where appropriate:

Source Records

42,450

Candidate Relationships

21,797,578

Cataloged Relationships

30,000

Golden Records

5,567

Consolidation Ratio

7.6 : 1

Deduplication Rate

86.9%

Precision Filter Rate

99.86%

DQ Pass Rate

98.9%

Total Actions Executed

22,268

Successful Executions

100%

RBAC Roles

4

Masking Policies

3

Version Layers

4

Source Systems

4

Metadata Tables

3

Business Rules

3

Core Processing Prompts

P10
P11
P12
P13
P14
P15
P16

---

Execution Environment

Target Environment

Snowflake Native Streamlit

Language

Python

Framework

Streamlit

Database Connectivity

Snowpark

Visualization Framework

Altair

Session Access

from snowflake.snowpark.context import get_active_session

Caching Standard

@st.cache_data(ttl=600)

The generated solution must execute without modification inside Snowflake Streamlit.

---

Success Criteria

The dashboard must clearly demonstrate:

✓ Relationship Discovery

✓ Relationship Cataloging

✓ Data Quality

✓ Golden Record Construction

✓ Metadata Governance

✓ Security Governance

✓ Auditability

✓ Architecture Transparency

✓ Interactive Record Exploration

✓ Relationship Lineage

✓ Version History

✓ Survivorship Transparency

✓ DQ-Weighted Discovery

✓ Governed AI Architecture

The dashboard must be suitable for:

* Hackathon Demonstrations
* Executive Showcases
* Architecture Reviews
* Governance Reviews
* MDM Capability Assessments

Execution shall:

Read Platform Data
↓
Read Governance Metadata
↓
Generate Business Visualizations
↓
Generate Technical Visualizations
↓
Generate Governance Visualizations
↓
Generate Security Visualizations
↓
Support Interactive Exploration
↓
Complete Successfully

The resulting dashboard must provide a complete business, technical and governance view of the Relationship Discovery Framework.

Generate complete executable Streamlit code.

---

END OF PROMPT
