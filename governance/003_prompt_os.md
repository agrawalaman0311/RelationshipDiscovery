# PROMPT OPERATING SYSTEM (PROMPT_OS)

Version: 1.0

Status: APPROVED

---

# 1. Purpose

PROMPT_OS defines the mandatory operating model for all Cortex interactions used to design and implement the Relationship Discovery Framework.

All prompts must comply with:

* MASTER_CONSTITUTION
* APPROVED_DECISIONS_REGISTER
* PROMPT_OS

---

# 2. Prompt Execution Model

Every prompt must follow:

Approved Inputs

↓

Single Prompt

↓

Single Artifact

↓

Human Review

↓

Approval

↓

Next Prompt

No prompt may bypass this sequence.

---

# 3. One Prompt = One Artifact

Every prompt must generate exactly one reviewable artifact.

Examples:

Valid:

* Source System Design
* Canonical Product Model
* DQ Framework
* Relationship Discovery Design

Invalid:

* Source System Design + DDL
* DQ Framework + SQL
* Relationship Design + Reporting Design

---

# 4. Future Phase Restriction

Prompts must only generate the requested artifact.

Prompts must not:

* Generate future artifacts
* Predict future designs
* Design downstream components

Example:

If asked to design source systems:

Do:

* Design source systems

Do Not:

* Generate DDL
* Generate BR
* Generate DAL
* Generate procedures

---

# 5. Prompt Inputs

Every prompt must explicitly state:

## Objective

Why the prompt exists.

## Inputs

Approved artifacts being consumed.

## Constraints

Applicable Constitution and ADR rules.

## Output Requirements

Expected artifact format.

---

# 6. Artifact Structure

Every Cortex artifact must contain:

## Objective

## Inputs

## Decisions Made

## Constraints Applied

## Approval Status

No additional sections are required.

---

# 7. Approval Gate

Every artifact must end with:

Approved

Approved With Changes

Rejected

No subsequent prompt may execute until approval is received.

---

# 8. AI Behavior Rules

Cortex must:

* Follow approved artifacts
* Respect ADR decisions
* Respect Constitution principles
* Stay within scope
* Generate deterministic outputs

Cortex must not:

* Redesign architecture
* Override approved decisions
* Introduce unapproved technologies
* Expand scope

---

# 9. Output Philosophy

Outputs must be:

* Reviewable
* Explainable
* Deterministic
* Concise

Outputs must not contain:

* Unnecessary rationale
* Alternative architectures
* Future recommendations
* Speculative enhancements

---

# 10. Governance Chain

Every implementation artifact must trace back to:

MASTER_CONSTITUTION

↓

APPROVED_DECISIONS_REGISTER

↓

PROMPT

↓

ARTIFACT

↓

IMPLEMENTATION

This chain must remain visible and auditable.

---

# 11. Git Requirements

Every approved artifact must be committed to Git.

Recommended sequence:

Prompt

↓

Artifact

↓

Approval

↓

Commit

This creates a complete audit trail of AI-assisted solution delivery.

---

# 12. Success Criteria

PROMPT_OS is successful when:

* Every prompt produces one artifact.
* Every artifact is reviewable.
* Every artifact is approved before continuation.
* Cortex behavior remains predictable.
* Full traceability exists from prompt to implementation.
