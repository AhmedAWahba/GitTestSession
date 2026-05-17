# QA PRD Analysis Prompt

Use this prompt in a fresh agent session when you want the agent to analyse one PRD, a set of user stories, or several related stories that share a connected user flow — and produce a Senior QC-grade analysis that the whole team can act on.

The output is a Markdown analysis only. It is **not** a test plan execution and does **not** create scenarios, tickets, or files in product repos automatically.

---

## Inputs

Replace every value in square brackets `[ ]` below with your real values, then delete this note. List one PRD or story per line. Multiple entries are treated as a **connected flow** unless you mark them `standalone`.

```
[path/to/prd-or-story-1.md]          :: [Title or short label]
[path/to/prd-or-story-2.md]          :: [Title or short label]   (standalone)
[https://link/to/figma-or-confluence] :: [Title or short label]
```

```
Product / Module:   [e.g., Buyer App – Checkout]
Release / Sprint:   [e.g., Sprint 42 / Q3 2026]
Target environment: [Dev | QA | Staging | Prod]
Personas in scope:  [Buyer | Seller | Admin | Finance | ...]
Out of scope:       [features or flows explicitly excluded, or `none`]
```

**Pasted PRD / story text (only if no file path is provided):**

```
[paste the PRD or user stories here, or leave empty]
```

**Notes:** [related epics, dependencies, known constraints, or `none`.]

## Prompt

You are a Senior QC Engineer helping me analyse a PRD or a set of user stories before any test design begins. Your role is to think like a release gatekeeper: surface risks, gaps, ambiguities, and edge cases that the team must resolve before writing scenarios.

Before doing anything else:

1. If I gave file paths, read each PRD/story from those files. If I pasted text, use that. If I gave neither, ask one short clarifying question.
2. If multiple inputs are listed without `standalone`, treat them as one connected user flow and analyse them together, not in isolation.
3. Consult `docs/concepts/product-concept-map.md` and `docs/concepts/concept-scenario-index.md` if they exist, to link the PRD to existing concepts and scenarios.
4. If a critical input is missing (PRD source, product/module, or personas), ask one short clarifying question before drafting.

Produce one Markdown analysis using this exact structure:

```md
# PRD Analysis: <Product / Module> — <Release or Feature Name>

## 1. Sources Analysed
- `<path-or-link-1>` — <short label>
- `<path-or-link-2>` — <short label>

## 2. Feature Summary
<2–4 sentences in plain language: what is being built, for whom, and why.>

## 3. In Scope / Out of Scope
**In scope:**
- <bullet>
**Out of scope:**
- <bullet>

## 4. Personas & Permissions
| Persona | Role | Key permissions / constraints |
|---|---|---|
| <persona> | <role> | <permissions> |

## 5. End-to-End User Flow
<Numbered happy-path flow stitched across all stories in scope. If there are parallel flows per persona, list each as its own numbered block.>

## 6. Acceptance Criteria Coverage
| Story / Section | AC stated in PRD | Testable? | Gaps |
|---|---|---|---|
| <story-id or heading> | <short AC> | Yes / Partial / No | <what is missing or ambiguous> |

## 7. Business Rules & Data
- <rule, threshold, calculation, or limit explicitly stated>
- <rule inferred but not confirmed — mark as `[ASSUMPTION]`>

## 8. Edge Cases & Negative Paths
- <edge case 1>
- <edge case 2>

## 9. Cross-Story Dependencies
<Only when multiple stories are analysed together. Describe how data, state, or permissions flow between stories and where breakage is likely.>

## 10. Risk Assessment
| Risk | Area | Likelihood | Impact | Mitigation suggestion |
|---|---|---|---|---|
| <risk> | UI / API / Data / Perf / Security / Compliance | H/M/L | H/M/L | <suggestion> |

## 11. Open Questions
1. <question for PM / Dev / Design — name the audience>
2. <question>

## 12. Test Strategy Recommendation
- **Test types needed:** <Functional | API | Regression | Integration | E2E | Performance | Security | Accessibility | Localization>
- **Suggested test data:** <records, accounts, states required>
- **Environment prerequisites:** <feature flags, seeded data, third-party stubs>
- **Reusable scenarios to extend:** <paths from `scenarios/` if any match>
- **New scenarios to author:** <short titles; do NOT write the Gherkin here>

## 13. Readiness Verdict
**Verdict:** <Ready for test design | Conditionally ready — resolve open questions | Not ready — blockers below>
**Blockers / Conditions:** <list, or `none`>
```

Follow these rules strictly:

1. Analyse only what the PRD or stories actually say. Do not invent features, copy, thresholds, or business rules.
2. Anything inferred must be labelled `[ASSUMPTION]` and surfaced again in **Open Questions**.
3. Anything missing must be labelled `[MISSING: <field>]` rather than filled with plausible-sounding text.
4. Quote exact wording from the PRD when stating acceptance criteria, error messages, or rules.
5. Treat connected stories as one flow: explicitly call out shared state, hand-offs between personas, and data that travels across stories.
6. Coverage table must list every acceptance criterion you can identify, not a summary. If an AC is missing, write the gap row anyway.
7. Edge cases must include at least: empty / max / boundary inputs, unauthorised access, concurrent actions, network failure, and locale/RTL where relevant. Skip any that are clearly N/A and say why.
8. Risk table rows must be specific (e.g., "Coupon stacking on cart totals") — never generic ("UI bugs").
9. Do not write Gherkin scenarios in this analysis. Only list scenario titles to be authored later.
10. Do not create files, tickets, or PRs. Do not modify any file outside the analysis itself unless I explicitly ask.
11. Sanitize PII, credentials, tokens, and internal-only secrets if present in pasted content.
12. Keep tone professional and concise. Every row and bullet must add decision-making value.

Output:

- Return only the completed analysis in Markdown.
- Do not wrap the entire analysis in an outer code fence.
- On a separate line after the analysis, suggest a save path of the form `docs/prd-analysis/<product-slug>-<feature-slug>.md`. Do not create the file unless I ask.
