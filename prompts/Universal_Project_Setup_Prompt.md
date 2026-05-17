# Universal Project Setup Prompt (Mirror Existing Repository First)

Use this prompt in a fresh agent session when you want the agent to set up a project by mirroring the current repository structure and installed dependency style first, then only adding what is explicitly requested.

---

## Inputs

Replace everything in square brackets `[ ]` with real values.

```txt
Project name: [my-project]
Setup mode: [mirror-current-project | generic] (default: mirror-current-project)
Project type: [automation | web-app | api | fullstack | library | cli | other]
Primary language: [javascript | typescript | python | java | csharp | go | rust | php]
Package manager: [npm | pnpm | yarn | pip | poetry | uv | maven | gradle | dotnet | go | cargo | composer]
Install Playwright tooling: [yes | no]
Install playwright-cli package explicitly: [yes | no]
Keep existing scenario hierarchy exactly: [yes | no] (default: yes)
Extra requirements: [none or list]
```

If you do not provide some values, infer safe defaults and mark them as `[ASSUMPTION]`.

## Prompt

You are a senior setup engineer. Set up the project while preserving the existing workspace shape.

### Primary objective

1. Mirror current repository structure and naming first.
2. Mirror currently installed dependency baseline first.
3. Install required packages only when requested.
4. Avoid adding new folders/files unless required.
5. Keep scenario files/folders unchanged unless explicitly requested.

### Mandatory preflight (do this first)

1. Scan the repository tree and summarize the existing structure.
2. Read `package.json` and `package-lock.json` (or equivalent lock file) to detect current dependencies.
3. Show a short plan before making changes:
- detected stack
- detected setup mode
- existing structure to preserve
- packages to install/update
- exact commands to run

### Mirror-current-project rules (strict)

If setup mode is `mirror-current-project`, apply all rules below:

1. Do not add new top-level convention folders (`src`, `tests`, `docs`, `config`, etc.) unless explicitly requested.
2. Preserve existing run script naming style at root (for example `run-*.js`).
3. Preserve existing directory naming and casing exactly.
4. Preserve `scenarios/` structure exactly as found in the repository. Do not create, rename, or flatten scenario folders/files unless explicitly requested.
5. Preserve existing helper/data folders and files under `fixtures/`.
6. Keep prompt documents under `prompts/` and Gherkin docs under `gherkin/`.
7. Preserve local tooling folders (for example `.playwright-cli/`, `.claude_skills/`) when present.

### GitTestSession structure profile (reference pattern)

When the current repository matches this profile, mirror it:

```txt
.
|- .claude_skills/
|  |- playwright-cli/
|     |- SKILL.md
|- .playwright-cli/
|- fixtures/
|  |- figma/
|  |- uploads/
|  |- *.js, *.json, *.yml
|- gherkin/
|  |- rubric.md
|  |- style-guide.md
|- prompts/
|  |- *.md
|- scenarios/
|  |- Admin/
|  |- Vendor-Store/
|  |- vendorApp/
|  |- prd1_payment_link_pack/
|  |- *.feature (inside the existing subfolders)
|- package.json
|- package-lock.json
|- run-*.js
```

### Required folder creation coverage (GitTestSession)

In `mirror-current-project` mode, if any of these folders are missing, create them to match the current project structure exactly:

```txt
.claude_skills/
.claude_skills/playwright-cli/
.playwright-cli/
fixtures/
fixtures/figma/
fixtures/uploads/
gherkin/
prompts/
scenarios/
scenarios/Admin/
scenarios/Vendor-Store/
scenarios/vendorApp/
scenarios/prd1_payment_link_pack/
```

Create only missing folders from this list. Do not rename or restructure existing ones.

PowerShell example:

```powershell
$folders = @(
	".claude_skills",
	".claude_skills/playwright-cli",
	".playwright-cli",
	"fixtures",
	"fixtures/figma",
	"fixtures/uploads",
	"gherkin",
	"prompts",
	"scenarios",
	"scenarios/Admin",
	"scenarios/Vendor-Store",
	"scenarios/vendorApp",
	"scenarios/prd1_payment_link_pack"
)
$folders | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }
```

Unix shell example:

```bash
mkdir -p \
	.claude_skills/playwright-cli \
	.playwright-cli \
	fixtures/figma \
	fixtures/uploads \
	gherkin \
	prompts \
	scenarios/Admin \
	scenarios/Vendor-Store \
	scenarios/vendorApp \
	scenarios/prd1_payment_link_pack
```

### Dependencies and installation rules

1. In Node automation projects like this one, treat `playwright` as the baseline runtime dependency.
2. Use the Playwright CLI provided by the `playwright` package via `npx playwright`.
3. Install browser binaries with `npx playwright install chromium`.
4. Only install `playwright-cli` as an extra package if the input explicitly says yes.
5. If explicit `playwright-cli` installation fails or package is unavailable, keep using `npx playwright` and report fallback clearly.
6. Do not remove existing dependencies unless explicitly requested.

### Command baseline for this repository style

```bash
npm install
npx playwright install chromium
```

If Playwright is missing:

```bash
npm install playwright
npx playwright install chromium
```

Optional explicit extra:

```bash
npm install -D playwright-cli
```

### Output format

Return one final Markdown report with this structure:

~~~md
# Project Setup Result

## 1. Detected Stack and Mode
- ...

## 2. Existing Structure Snapshot
~~~txt
<tree>
~~~

## 3. Changes Applied
- folders created/updated
- files created/updated

## 4. Dependencies
- existing baseline detected
- newly installed
- skipped (with reason)

## 5. Commands Executed
~~~bash
...
~~~

## 6. Verification Results
- command + pass/fail + short output

## 7. Assumptions
- [ASSUMPTION] ...

## 8. Notes
- structure compatibility status: matched / partially matched / deviated
- if deviated, list exact reason
~~~

### Hard constraints

1. Mirror existing repository structure first.
2. Do not invent new scenario file names.
3. Do not restructure `scenarios/` unless explicitly requested.
4. Do not add generic folders in mirror mode.
5. Keep the setup reusable, but prioritize current repository compatibility over generic templates.
