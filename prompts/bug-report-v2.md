# QA Bug Report Prompt (v2)

Use this prompt in a fresh agent session when you want the agent to draft a structured bug report from a failed Gherkin scenario. The report is drafted as Markdown only — it is **not** published to any product repo automatically.

---

## Inputs

Replace every value in square brackets `[ ]` below with your real values, then delete this note.

```
Scenario file:    [path/to/scenario.feature]   (or paste the scenario under "Scenario text" below)
Scenario name:    [Exact Scenario Name From The File]
Evidence folder:  [evidence/<run-timestamp>/<NNN>-<scenario-slug>/]
Product:          [product name / module, e.g. "Sign-Up (onboarding)" or "Invoices (pearl)"]
Environment:      [Dev | QA | Staging | Prod]   URL: [https://...]
Branch:           [git branch being tested, e.g. feature/sign-up-flow | main | release/1.2.0]
Browser:          [name + version, e.g. Chrome 125]
Device:           [Desktop | Mobile | Tablet]
OS:               [name + version, e.g. Windows 11 | macOS 14 | iOS 17]
What happened:    [one or two sentences describing what you observed]
Notes:            [related tickets, workaround, suspected area, or "none"]
```

**Scenario text (only if no file path is provided):**

```gherkin
[paste the scenario here, or leave empty]
```

---

## Prompt

You are helping me draft a bug report from a failed Gherkin scenario.

Before doing anything else:

1. Load and use the included `write-bug-report` skill if available.
2. If I gave a scenario file path, read the scenario from it. If I pasted scenario text, use that. If I gave neither, ask one short clarifying question.
3. List the contents of the evidence folder and use the actual file names. Do not rename, reorder, or invent evidence files. If the folder is missing or empty, write "No screenshots provided. Attach manually." in the Evidence section.
4. If the scenario or "what happened" is missing, ask one short clarifying question before drafting.

Produce one Markdown bug report using this exact structure:
# Title
<Area>: <problem> when <action>

## Environment
- **Product:** <product name / module>
- **Environment:** <Dev | QA | Staging | Prod> — <URL>
- **Branch:** <git branch, e.g. feature/sign-up-flow>
- **Date/Time:** <YYYY-MM-DD>
- **Browser:** <name + version> — **Device:** <Desktop | Mobile | Tablet> — **OS:** <name + version>

## Scenario
​```gherkin
<full scenario text>
​```

## Steps to Reproduce
1. <first manual step>
2. <second manual step>
3. …

## Expected Behaviour
<what should happen per the scenario>

## Actual Behaviour
<exactly what happened — quote visible text, error messages, status codes>

## Additional Context
<related tickets, workaround, suspected area, or "none">

## Evidence
- `<path/to/file.png>` — <what it shows>
- (If no evidence: "No screenshots provided. Attach manually.")
```

Follow these rules strictly:

1. The title must follow `<Area>: <problem> when <action>` and stay ≤ 12 words.
2. Embed the full scenario text in a fenced `gherkin` block. Do not paraphrase it.
3. Steps to Reproduce must be concrete manual steps a developer can follow, derived from the scenario flow. Do not copy the Gherkin steps verbatim — translate them into numbered click-by-click actions.
4. Expected Behaviour must come from the scenario. Actual Behaviour must describe only what was observed.
5. Quote exact visible text, error messages, and status codes when they appear in the evidence or description. If exact wording is unknown, describe the behaviour without inventing copy.
6. Use evidence file paths exactly as they appear on disk.
7. Do not invent root causes, business rules, error codes, or steps that were not observed or provided.
8. Sanitize PII, credentials, tokens, and secrets.
9. For any required field not supplied, insert `[MISSING: <field>]` rather than guessing.
10. If the bug is an API issue, append a short `## API Details` section: Endpoint, Method, Request (sanitized), Actual Status + Response, Expected Status.
11. Do not create a GitHub issue, do not publish to any product repo, and do not modify any files unless explicitly asked.

Output:

- Return only the completed bug report in Markdown.
- Do not wrap the entire report in an outer code fence.
- On a separate line after the report, suggest a save path of the form `reported bugs/<product> - <short-symptom>.md`. Do not create the file unless asked.
