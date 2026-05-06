# Gherkin Style Guide

Keep scenarios clear, observable, and executable.

## Principles

1. Write behaviour, not implementation noise.
2. Make preconditions explicit.
3. Make outcomes observable.
4. Keep one coherent behaviour per scenario.
5. Use language the team already understands.

## Structure

- `Feature`: one file per feature area, with a brief description
- `Background`: shared preconditions across all scenarios in a file
- `Scenario`: a single, atomic behaviour
- `Scenario Outline`: parameterised behaviour with multiple data combinations
- `Given`: context and preconditions
- `When`: actions
- `Then`: expected outcomes
- `And` / `But`: extend the previous keyword's meaning

## Good Practices

- State environment assumptions when they matter (URL, role, language).
- Name pages, headings, buttons, and fields clearly.
- Prefer visible outcomes: redirects, headings, validation messages, list changes, toasts.
- Include cleanup only when the scenario creates state and cleanup matters.
- One scenario should be understandable without reading others in the same file.

## Data Patterns

### Inline Values

Use when there are 1-2 simple values directly relevant to the behaviour:

```gherkin
Scenario: Login with valid credentials
  Given I am on the login page
  When I log in as "admin@example.com" with password "correct-password"
  Then I should be redirected to the dashboard
```

### Data Tables

Use for structured input with multiple fields:

```gherkin
Scenario: Create a new notification
  Given I am logged in as an admin
  When I create a notification with the following details:
    | Field   | Value                          |
    | Title   | System Maintenance             |
    | Body    | Scheduled downtime at 2am      |
    | Target  | All Users                      |
  Then the notification should appear in the notifications list
```

### Scenario Outlines with Examples

Use when the same behaviour must be verified with multiple data combinations:

```gherkin
Scenario Outline: Login fails with invalid credentials
  Given I am on the login page
  When I log in as "<email>" with password "<password>"
  Then I should see a validation error "<message>"

  Examples:
    | email              | password | message                    |
    | wrong@example.com  | any      | Invalid email or password  |
    | admin@example.com  | wrong    | Invalid email or password  |
    |                    | any      | Email is required          |
```

### Multi-row Data Tables

Use for verifying lists or collections:

```gherkin
Scenario: Dashboard shows recent notifications
  Given I am logged in as an admin
  And the following notifications exist:
    | Title              | Status    |
    | System Maintenance | Sent      |
    | New Feature        | Draft     |
    | Security Update    | Scheduled |
  When I navigate to the notifications page
  Then I should see all notifications listed
```

## Common Scenario Conventions

Scenarios in `scenarios/common/` are reusable building blocks. They should:

- Be short and atomic (one action, one clear outcome)
- Be self-contained (no dependencies on other common scenarios)
- Represent frequently-repeated flows (login, navigate, create basic resource)
- Serve as smoke tests when run independently
- Use generic, product-agnostic language where possible

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| `Then it works` | Vague, unverifiable | State the specific observable outcome |
| `Then an error appears` | Which error? Where? | Quote the expected message or describe its location |
| Missing login/page context | Agent cannot start reliably | Add explicit Given steps for auth and navigation |
| Click-by-click instructions | Brittle, hard to read | Describe the action at a higher level |
| Multiple behaviours in one scenario | Hard to diagnose failures | Split into separate scenarios |
| Hardcoded waits or timing | Fragile across environments | Describe expected state, not timing |
| UI implementation details | Breaks when UI changes | Use business language, not CSS selectors |
| Enormous scenarios (10+ steps) | Hard to follow, likely multi-behaviour | Split or simplify |

## Review Standard

A scenario does not need to match any canonical wording exactly.

It does need to be:

- clear enough for a human to follow;
- clear enough for an agent to execute;
- specific enough to verify the outcome.
