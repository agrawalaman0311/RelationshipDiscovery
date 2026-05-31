# PROMPT 001 – GENERATE PLATFORM SETUP

## Objective

Generate the Snowflake SQL required to create the approved database and schema structure for the Relationship Discovery Framework.

## Output Location

sql/platform/001_database_and_schema_setup.sql

Generate the contents of this file.

Do not generate any other files.

---

## Governance Inputs

Read and comply with:

* governance/001_MASTER_CONSTITUTION.md
* governance/002_APPROVED_DECISIONS_REGISTER.md
* governance/003_PROMPT_OS.md
* governance/004_PROJECT_CONTEXT.md
* governance/005_METADATA_DESIGN.md

All approved decisions are mandatory.

---

## Approved Decisions

Database:

RELATIONSHIP_DISCOVERY_DB

Schemas:

* SRC
* MD
* LOG
* INTM
* FINAL
* RPT

---

## Task

Generate Snowflake SQL to:

1. Create the database if it does not exist.
2. Create all approved schemas if they do not exist.

---

## Constraints

Do NOT generate:

* Tables
* Views
* Procedures
* Tasks
* Metadata Objects
* DQ Objects
* Relationship Discovery Objects
* BR Objects
* DAL Objects
* Test Data
* Reporting Objects

Generate platform setup SQL only.

---

## Output Requirements

Output must contain executable Snowflake SQL only.

Do not include:

* Explanations
* Markdown
* Comments
* Documentation
* Alternative approaches

---

## Success Criteria

The generated SQL must execute successfully and establish the approved platform structure required for future artifacts.

The next artifact will be:

sql/source/002_source_tables.sql
