# Gherkin Review Rubric

Use this rubric to review a scenario for clarity, execution readiness, and quality.

For a `.feature` file with multiple scenarios, apply the rubric to each scenario individually, then add a short feature-level coherence summary.

## Quick Outcome

- **Ready**: clear enough for a human and an agent to execute reliably. Can be merged.
- **Almost ready**: usable, but has one or two important weaknesses. Fixable in one pass.
- **Not ready**: too ambiguous or incomplete to execute confidently. Needs rethinking.

## Readiness Gates

If ANY of these fail, the scenario is **Not ready**.

1. **Clear start**: starting context, state, and prerequisites are explicit.
2. **Clear actions**: actions are unambiguous and easy to follow.
3. **Clear outcomes**: success or failure is observable and specific.
4. **Contained scope**: the scenario covers one coherent behaviour.

## Quality Dimensions

Rate each as **Strong**, **Needs work**, or **Weak**.

### 1. Preconditions and Context
Is the setup explicit enough to start reliably? Does it state authentication, navigation, language, and environment where relevant?

### 2. Action Clarity
Are the actions specific and easy to follow without guessing? Could someone unfamiliar with the product execute them?

### 3. Assertion Quality
Are the expected outcomes visible, concrete, and testable? Do they describe what the user can see or measure?

### 4. Behaviour Focus
Does the scenario describe behaviour rather than brittle UI choreography? Is it written in business language?

### 5. Completeness for Execution
Does the scenario include the assumptions needed for safe, sensible execution? Are environment and role dependencies stated?

### 6. Data Richness
Are data tables, Examples sections, or inline values used appropriately? Is the test data realistic and sufficient to exercise the behaviour? Could a Scenario Outline replace duplicated scenarios?

### 7. Independence
Can this scenario run without depending on the outcome of another scenario? Does it set up its own preconditions?

### 8. Naming
Is the scenario name descriptive of the specific behaviour being tested? Would someone scanning a list of scenario names understand what each one covers?

## Common-Scenario Candidacy

After reviewing, ask: should this scenario (or part of it) live in `scenarios/common/`?

Criteria for common scenarios:
- Repeated across multiple domain scenarios (e.g., login flow)
- Short and atomic (single action, single outcome)
- Product-agnostic or broadly reusable

If yes, note this in the review feedback.

## Anti-pattern Flags

Call these out explicitly when present:

- Vague outcome
- Missing precondition
- Hidden assumption
- Implementation leakage
- Multiple behaviours mixed together
- Unclear validation expectation
- Missing cleanup where state is created
- Environment or role unstated
- Duplicated scenarios that should be an Outline

## Coaching Summary

End every review with:

1. One strength.
2. One highest-value improvement.
3. One concise next-step recommendation.
