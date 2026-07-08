# Gherkin Review Report: prd2_payment_execution_pack

Date: 2026-07-08
Scope: scenarios/prd2_payment_execution_pack
Standards used:
- gherkin/rubric.md
- gherkin/style-guide.md

## Files Reviewed
- scenarios/prd2_payment_execution_pack/apple-pay-payment-cycle.feature
- scenarios/prd2_payment_execution_pack/arb-payment-test.feature
- scenarios/prd2_payment_execution_pack/arb_guest_payment_cycle.feature
- scenarios/prd2_payment_execution_pack/arb_registered_payment_cycle.feature
- scenarios/prd2_payment_execution_pack/seller_payment_link_preconditions.feature

## Findings (Ordered by Severity)

### 1. High: Mixed behaviors in one scenario (reject + fallback success)
- File: scenarios/prd2_payment_execution_pack/arb_guest_payment_cycle.feature
- Lines: 40+
- Issue: A single scenario includes ARB rejection and then a complete fallback payment success path.
- Why this matters: Violates contained scope and one-coherent-behavior rule; makes failures harder to diagnose.
- Rubric/Style impact:
  - Readiness Gate 4: Contained scope
  - Style principle: Keep one coherent behavior per scenario
- Recommendation: Split into two scenarios:
  - Rejection behavior only
  - Retry/fallback success behavior

### 2. High: Ambiguous assertion with multiple acceptable outcomes
- File: scenarios/prd2_payment_execution_pack/apple-pay-payment-cycle.feature
- Line: 140
- Text: "Then the final payment status should be shown as unresolved or failed"
- Issue: The expected result is non-deterministic.
- Why this matters: Reduces execution reliability and weakens pass/fail criteria.
- Rubric/Style impact:
  - Readiness Gate 3: Clear outcomes
- Recommendation: Use deterministic expected status per condition, or split into scenario outline with explicit expected result by condition.

### 3. Medium: Dynamic assertion token in Scenario Outline reduces clarity
- File: scenarios/prd2_payment_execution_pack/arb-payment-test.feature
- Line: 65
- Text: "And <warning_assertion>"
- Issue: Step text itself is templated instead of value-driven.
- Why this matters: Lowers readability and can complicate step-definition stability.
- Rubric/Style impact:
  - Action clarity
  - Assertion quality
- Recommendation: Replace with explicit assertion steps and value columns (e.g., warning expected yes/no + message).

### 4. Medium: Empty expected warning value in examples
- File: scenarios/prd2_payment_execution_pack/seller_payment_link_preconditions.feature
- Lines: 55, 60
- Issue: Expected warning is empty for available threshold case.
- Why this matters: Leaves assertion intent ambiguous.
- Rubric/Style impact:
  - Assertion quality
  - Completeness for execution
- Recommendation: Split the boundary behavior into two explicit assertions:
  - unavailable + warning shown
  - available + warning not shown

### 5. Medium: Hidden state assumptions for retry scenarios
- Files:
  - scenarios/prd2_payment_execution_pack/apple-pay-payment-cycle.feature (line 147)
  - scenarios/prd2_payment_execution_pack/arb-payment-test.feature (line 195)
- Issue: "previous attempt has failed" is assumed without a deterministic setup mechanism.
- Why this matters: Risks non-repeatable runs and inter-scenario dependencies.
- Rubric/Style impact:
  - Independence
  - Completeness for execution
- Recommendation: Make prior failed-attempt state explicit through setup/seed steps in Given.

### 6. Low: Repeated setup patterns are candidates for common scenario extraction
- Files:
  - scenarios/prd2_payment_execution_pack/arb_guest_payment_cycle.feature (line 16)
  - scenarios/prd2_payment_execution_pack/arb_registered_payment_cycle.feature (line 17)
- Issue: Similar login/open-link setup appears repeatedly.
- Why this matters: Increases maintenance overhead and drift risk.
- Rubric/Style impact:
  - Common-scenario candidacy
- Recommendation: Extract reusable setup blocks into common scenarios where your test framework supports it.

## Feature-Level Verdict
- scenarios/prd2_payment_execution_pack/apple-pay-payment-cycle.feature: Almost ready
- scenarios/prd2_payment_execution_pack/arb-payment-test.feature: Almost ready
- scenarios/prd2_payment_execution_pack/arb_guest_payment_cycle.feature: Almost ready
- scenarios/prd2_payment_execution_pack/arb_registered_payment_cycle.feature: Ready
- scenarios/prd2_payment_execution_pack/seller_payment_link_preconditions.feature: Almost ready

## Coaching Summary
1. Strength: Coverage breadth is strong across positive, negative, retry, status, and compatibility paths.
2. Highest-value improvement: Split mixed-behavior scenarios and remove ambiguous expected outcomes.
3. Next-step recommendation: Run one targeted style-cleanup pass on the five findings above, then re-review with the same rubric gates.
