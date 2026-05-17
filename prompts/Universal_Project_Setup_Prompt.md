# Universal Project Setup Prompt (Any Tech Stack)

Use this prompt in a fresh agent session when you want the agent to scaffold a complete project structure and install all required packages for any project type (web app, API, mobile backend, automation, data app, or library).

---

## Inputs

Replace everything in square brackets `[ ]` with real values.

```txt
Project name: [my-project]
Setup mode: [mirror-current-project | generic]
Project type: [web-app | api | fullstack | mobile-backend | automation | data-pipeline | library | cli]
Primary language: [typescript | javascript | python | java | csharp | go | rust | php]
Framework/runtime: [nextjs | react-vite | express | fastapi | django | spring-boot | dotnet | gin | none]
Package manager: [npm | pnpm | yarn | pip | poetry | uv | maven | gradle | dotnet | go | cargo | composer]
Database (optional): [postgres | mysql | mongodb | sqlite | redis | none]
Testing: [unit | integration | e2e | none]
Lint/format: [eslint+prettier | ruff+black | golangci-lint | none]
Deployment target: [docker | k8s | serverless | vm | static-hosting | none]
OS target: [windows | linux | macos | cross-platform]
Monorepo: [yes | no]
Extra requirements: [auth, queues, caching, message broker, observability, etc. or none]
``` 

If you do not provide some values, infer safe defaults and clearly mark them as `[ASSUMPTION]`.

## Prompt

You are a senior setup engineer. Build a production-ready starter structure for the project I specified.

Your objective is to:
1. Create the correct folder structure.
2. Initialize the project with the selected language/framework.
3. Install all required dependencies and dev dependencies.
4. Add runnable scripts/commands for dev, test, lint, build, and start.
5. Add baseline configuration files.
6. Make the setup reproducible for future projects.

Follow these rules strictly:

1. Work stack-agnostically. Do not assume any brand-specific product, domain, or project names.
2. If values are missing, choose practical defaults and label them `[ASSUMPTION]` in the summary.
2.1 Preserve the existing repository structure when it already exists. Do not introduce new top-level folder conventions unless explicitly requested.
2.2 For BDD or test scenarios, keep a single `scenarios/` root only. Do not create persona/environment subfolders (for example admin/app/vendor) unless explicitly requested.
2.3 Do not invent new scenario file names. Reuse existing `.feature` files when present; if none exist, ask before creating any scenario file.
2.4 If `Setup mode` is `mirror-current-project`, follow this repository pattern first and do not add generic folders like `src/` or `tests/` unless explicitly requested:
- root scripts: `run-*.js`
- folders: `fixtures/`, `gherkin/`, `prompts/`, `scenarios/`
- optional local tool folder: `.playwright-cli/`
3. Before generating files, show a short setup plan including:
- detected stack
- detected setup mode (`mirror-current-project` or `generic`)
- folders to create
- packages to install
- commands to run
4. Create a clean and conventional structure based on project type:
- `src/`, `tests/`, `docs/`, `scripts/`, `config/`, `.github/workflows/` when applicable
- add feature folders if fullstack/large project
 - if a project already has established folders, prioritize that structure over generic conventions
 - if `Setup mode` is `mirror-current-project`, keep only the existing top-level structure and avoid introducing new convention folders
5. Create/update baseline files where relevant:
- `README.md`
- `.gitignore`
- `.env.example`
- package/build config (`package.json`, `pyproject.toml`, `pom.xml`, etc.)
- linter/formatter config
- test config
- Docker files if deployment target requires it
6. Install dependencies using the chosen package manager.
6.1 For Node.js automation projects in `mirror-current-project` mode, install and verify this baseline first:
- runtime dependency: `playwright`
- CLI/tooling dependency: `playwright-cli` when available in registry
- browser binaries: `chromium` via Playwright install command
 - npm command baseline:
	 - `npm install playwright`
	 - `npm install -D playwright-cli` (if available)
	 - `npx playwright install chromium`
6.2 If `playwright-cli` is unavailable in the package registry, continue with `playwright` + `npx playwright` commands and report the fallback clearly.
7. Prefer widely adopted and stable packages.
8. Add minimal example app/module so the project runs immediately after setup.
9. Add scripts/commands for:
- development
- testing
- linting
- formatting
- build
- production run
10. Validate setup by running the relevant verification command(s) (for example: build, lint, or test smoke command).
11. If a command fails, fix once and retry. If still failing, report exact blocker and next action.
12. Never include secrets. Put placeholders in `.env.example`.
13. Keep generated content concise and maintainable.

Output format:

Return one final markdown report with these sections:

```md
# Project Setup Result

## 1. Detected / Selected Stack
- ...

## 2. Folder Structure Created
```txt
<tree>
```

## 3. Dependencies Installed
- Runtime: ...
- Dev: ...

## 4. Commands Executed
```bash
...
```

## 5. Files Generated
- path + short purpose

## 6. Verification Results
- command + pass/fail + short output

## 7. Assumptions
- [ASSUMPTION] ...

## 8. Next Recommended Steps
1. ...
2. ...
```

Important constraints:
- Do not hardcode Qawafel, vendor/admin flows, or any project-specific business domain.
- Make the setup reusable for any team.
- Use cross-platform commands where possible; when OS-specific, provide Windows and Unix variants.
- Keep scenario organization flat under `scenarios/` unless the user explicitly requests nested scenario folders.
- Do not create new scenario file names without explicit approval when existing scenario files already exist.
- In `mirror-current-project` mode, do not create `scenarios/admin`, `scenarios/app`, or any persona-based scenario subfolder by default.
- In `mirror-current-project` mode, keep current run script naming (`run-*.js`) unless explicitly asked to rename.
