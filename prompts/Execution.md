# QA Execution Prompt

Use this prompt in a fresh agent session when you want the agent to execute one or more Gherkin scenarios — from one or several `.feature` files — against the appropriate Qawafel development system.
---

## Scenarios to run

Replace every value in square brackets `[ ]` below with your real values, then delete this note. Keep the format `path :: Scenario Name` (one per line). Use `:: *` to run every scenario in a file.

```
[path/to/first-file.feature] :: [Exact Scenario Name From The File]
[path/to/second-file.feature] :: [Another Scenario Name]
[path/to/third-file.feature] :: *
```

**Notes:** [add any run-specific notes here, or write `none`. Include `stop-on-failure` if you want the run to stop at the first failure.]

## Prompt

You are helping me execute one or more Gherkin scenarios.

Your job is to execute only the scenarios I list against the appropriate Qawafel development system using `playwright-cli`.

Before doing anything else:

1. Load and use the included `playwright-cli` skill.
2. Read `fixtures/credentials.yml` for environment URLs, usernames, passwords, mobile numbers, OTP values, and any other credentials. Use those values rather than guessing.
3. I will give you a list of scenarios. Each entry is in the form `[path/to/file.feature] :: [Scenario Name]`, one per line. The form `[path/to/file.feature] :: *` means "every scenario in that file." Entries may come from different files.
4. If I provide pasted scenario text instead of a list, treat it as a single scenario.
5. If anything is missing or ambiguous, ask one short clarifying question before proceeding.

Follow these rules strictly:

1. Execute only the scenarios I listed, in the order I listed them. Do not infer or add other scenarios.
2. Use `playwright-cli` in `--headed` mode so the default browser is used and activity is visible. If the browser is not visible, do not proceed.
3. For each scenario, read it carefully and follow its preconditions, actions, and expected outcomes. Reuse helper scripts in `fixtures/` (for example `fill-step1.js`, `select-city.js`, `upload-files.js`, `check-errors.js`) when they match a step.
4. Start each scenario from a clean browser context (fresh cookies and storage) unless the scenario clearly depends on the previous one.
5. If one scenario fails or is blocked, continue with the remaining scenarios. Stop early only if I wrote `stop-on-failure` in the notes.
6. Store all evidence under `evidence/<run-timestamp>/<NNN>-<scenario-slug>/`, where `<NNN>` is the scenario's position in the list (`001`, `002`, …).
7. Capture a screenshot after every meaningful step, using a clear numbered sequence so the evidence is complete even if the scenario fails part-way through. Name screenshots with a three-digit numeric prefix and a short description, for example `001-login-page.png`, `002-otp-screen.png`, `003-validation-error.png`.
8. Capture browser console output, page errors, and failed network requests (status ≥ 400) when `playwright-cli` exposes them, and include that information in the per-scenario summary.
9. During execution, give brief milestone updates only at meaningful points. Do not narrate every action.
10. If a scenario passes, summarise what happened and list the evidence captured. If it fails, stop that scenario cleanly at the failure point, capture the final state, and summarise the observed failure without inventing missing details.
11. Do not create bug reports or GitHub issues unless I explicitly ask.
12. Do not perform destructive or risky actions beyond what a scenario clearly requires.
13. If the application behaves unexpectedly, report exactly what you observed.

Execution style:

- Be precise and literal.
- Prefer clear, reversible actions.
- Separate what each scenario expected from what the application actually did.
- Treat screenshots and logs as evidence, not decoration.
- Keep the browser visible throughout the run.
- Use the credentials and URLs from `fixtures/credentials.yml` as the source of truth.

At the end of the whole run, give one combined summary: a short table or list with each scenario's name, final status (PASS / FAIL / BLOCKED with reason), the step where it ended, and the path to its evidence folder; then an overall result (for example "5 PASS, 1 FAIL, 0 BLOCKED") and any notable console or network anomalies.


