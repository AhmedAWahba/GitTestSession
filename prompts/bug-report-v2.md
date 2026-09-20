# QA Bug Report Prompt

Use this prompt in a fresh agent session when you want the agent to draft a structured bug report from a failed Gherkin scenario. The report is drafted as Markdown only — it is **not** published to any product repo automatically.

---

## Inputs

Replace every value in square brackets `[ ]` below with your real values, then delete this note.

```
Scenario file:    [path/to/scenario.feature]   (or paste the scenario under "Scenario text" below)
Scenario name:    [Exact Scenario Name From The File]
Evidence folder:  [evidence/<run-timestamp>/<NNN>-<scenario-slug>/]
Environment:      [Dev | QA | Staging | Prod]   URL: [https://...]
What happened:    [one or two sentences describing what you observed]
```

**Scenario text (only if no file path is provided):**

```gherkin
[paste the scenario here, or leave empty]
```

**Notes:** [related tickets, suspected severity, or `none`.]

**important:** [follow up the follwing strcture and don't add any section before ask the user]

## Prompt

You are helping me draft a bug report from a failed Gherkin scenario.

Before doing anything else:

1. Load and use the included `write-bug-report` skill if available.
2. If I gave a scenario file path, read the scenario from it. If I pasted scenario text, use that. If I gave neither, ask one short clarifying question.
3. List the contents of the evidence folder and use the actual file names. Do not rename, reorder, or invent evidence files.
4. If the scenario, evidence folder, or "what happened" is missing, ask one short clarifying question before drafting.

Produce one Markdown bug report using this exact structure:

# Title
Write a concise, one-line title that clearly describes the issue.
Use the format: [Web/Mobile] - [Area] - [Problem] when [Action]

<[Web/Mobile] - [Area] - [Problem] when [Action]>

## Summary
<one short paragraph describing the defect clearly and concretely>

## Scenario
​```gherkin
<scenario text here>
<start with the actor role if admin or user>
​```

## Expected Result
<what should have happened according to the scenario>

## Actual Result
<what actually happened during execution>

## Evidence
- `evidence/<run>/<scenario>/<file-1>.png` — <what it shows>
- `evidence/<run>/<scenario>/<file-2>.png` — <what it shows>

## Environment
- **Product:** <product name / module>
- **Environment:** <Dev | QA | Staging | Prod> — <URL>
- **Branch:** <git branch, e.g. feature/sign-up-flow>
- **Date/Time:** <YYYY-MM-DD>
- **Browser:** <name + version> — **Device:** <Desktop | Mobile | Tablet> — **OS:** <name + version>
```

Follow these rules strictly:

1. The title must follow `<Area>: <problem> when <action>` and stay ≤ 12 words.
2. The Summary must be one short paragraph — concrete, not vague.
3. Embed the scenario inline in a fenced `gherkin` block. Do not paraphrase it.
4. Expected Result must come from the scenario. Actual Result must describe only what was observed.
5. Quote exact visible text, error messages, and status codes when they appear in the evidence or my description. If the exact wording is unknown, describe the behaviour without inventing copy.
6. Use evidence file paths exactly as they appear on disk.
7. Do not invent root causes, business rules, error codes, or steps that were not observed or provided.
8. Sanitize PII, credentials, tokens, and secrets.
9. For any required field I did not supply, insert `[MISSING: <field>]` rather than guessing.
10. If the bug is an API issue, append a short `## API Details` section with: Endpoint, Method, Request (sanitized), Actual Status + Response, Expected Status.
11. If the bug is a UI issue, include Browser + Version, Device Type, and OS + Version on the Environment line.
12. Do not create a GitHub issue, do not publish to any product repo, and do not modify any files outside the report itself unless I explicitly ask.

Severity quick reference:

- **Critical** — crash, data loss, security breach, no workaround.
- **High** — major feature broken, painful workaround.
- **Medium** — partial breakage, workaround available.
- **Low** — cosmetic or minor UX, no functional impact.

Priority quick reference:

- **P1** Urgent / Blocker · **P2** High · **P3** Medium · **P4** Low / Cosmetic.

Output:

- Return only the completed bug report in Markdown.
- Do not wrap the entire report in an outer code fence.
- On a separate line after the report, suggest a save path of the form `bug-reports/<scenario-slug>-<short-symptom>.md`. Do not create the file unless I ask.
