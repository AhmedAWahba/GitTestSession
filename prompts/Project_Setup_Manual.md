# Qawafel BDD Test Project — User Manual

## Project Setup & Structure Guide

**Version:** 2.0  
**Date:** April 28, 2026  
**Author:** QA Team  

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Project Initialization](#3-project-initialization)
4. [Folder Structure](#4-folder-structure)
5. [Configuration Files](#5-configuration-files)
6. [Run Scripts](#6-run-scripts)
7. [Writing Feature Files (Gherkin Scenarios)](#7-writing-feature-files)
8. [Prompt Templates](#8-prompt-templates)
9. [Execution Workflow](#9-execution-workflow)
10. [Evidence Collection](#10-evidence-collection)
11. [Bug Reporting](#11-bug-reporting)
12. [GitHub Issue Publishing](#12-github-issue-publishing)
13. [Fixtures & Helper Scripts](#13-fixtures--helper-scripts)
14. [Complete Prompt Reference](#14-complete-prompt-reference)

---

## 1. Overview

This project is a **BDD (Behavior-Driven Development) manual testing framework** powered by:
- **Gherkin `.feature` files** for scenario authoring
- **Node.js Playwright scripts** (`run-*.js`) for automated browser execution with headed Chromium
- **GitHub Copilot Agent** (Claude) as the AI execution engine
- **GitHub CLI (`gh`)** for bug report publishing

The framework covers **three environments** of the Qawafel platform:
| Environment | URL | Purpose |
|-------------|-----|---------|
| **Vendor Store** | `https://store.development.qawafel.dev` | B2B vendor self-registration |
| **Admin Panel** | `https://admin.development.qawafel.dev` | Registration approval & verification |
| **Vendor App** | `https://app.development.qawafel.dev` | Vendor login & post-approval access |

The main test flows are:
1. **Registration** — full B2B store registration (phone → OTP → Step 1 form → Step 2 documents → pending popup)
2. **Admin Approval** — admin logs in and approves a pending registration in the verification center
3. **End-to-End** — both flows combined in one automated run
4. **Vendor Login** — comprehensive positive and negative login scenario coverage on the vendor app

---

## 2. Prerequisites

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| **Node.js** | v18+ | Runtime & package management | [nodejs.org](https://nodejs.org) |
| **npm** | Bundled with Node.js | Install project dependencies | - |
| **VS Code** | Latest | IDE with Copilot agent | [code.visualstudio.com](https://code.visualstudio.com) |
| **GitHub Copilot** | Latest extension | AI agent for scenario execution | VS Code Marketplace |
| **GitHub CLI (`gh`)** | Latest | Publish bug reports as GitHub issues | `winget install GitHub.cli` |
| **Playwright** | ^1.59.1 | Chromium browser automation | Installed via `npm install` |

> **Note:** `playwright-cli` is no longer required. All test execution is done via direct Node.js Playwright scripts (`node run-*.js`).

---

## 3. Project Initialization

### Step 1: Clone or create the project folder

```powershell
# Option A – clone existing repo
git clone <repo-url> GitTestSession
cd GitTestSession

# Option B – create from scratch
mkdir GitTestSession
cd GitTestSession
```

### Step 2: Initialize Node.js project

```powershell
npm init -y
```

The current `package.json` for this project:
```json
{
  "name": "git_test-project",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "type": "commonjs",
  "dependencies": {
    "playwright": "^1.59.1"
  }
}
```

### Step 3: Install dependencies

```powershell
npm install
```

This installs the **Playwright** library (v1.59.1+) into `node_modules/`.

### Step 4: Install Playwright browsers

```powershell
npx playwright install chromium
```

This downloads the headless/headed Chromium browser binary used by all run scripts.

### Step 5: Create all required directories

```powershell
mkdir scenarios\Admin
mkdir scenarios\vendorApp
mkdir fixtures\uploads
mkdir prompts
mkdir evidence
mkdir bug_reports
```

### Step 6: Populate upload test files

Place the following files in `fixtures/uploads/` for document upload scenarios:

| File | Purpose |
|------|---------|
| `commercial-registration.jpg` | Valid CR document (JPG) |
| `commercial-registration.png` | Valid CR document (PNG) |
| `vat-certificate.jpg` | Valid VAT certificate (JPG) |
| `vat-certificate.png` | Valid VAT certificate (PNG) |
| `large-file.jpg` | Oversized file — for negative upload tests |
| `fake-image.exe` | Invalid file type — for negative upload tests |
| `test.bmp` | BMP format — for negative upload tests |
| `test.svg` | SVG format — for negative upload tests |

### Step 7: Initialize the run counter

Create `fixtures/run-counter.json` with:
```json
{
  "counter": 1
}
```

This file tracks the current test run number so that every run generates a unique mobile number, email, CR number, and VAT number. It is auto-incremented after each successful registration run.

### Step 8: Authenticate GitHub CLI

```powershell
gh auth login --hostname github.com --git-protocol https --web
```

---

## 4. Folder Structure

```
GitTestSession/
│
├── package.json                              # Node.js project config + dependencies
├── run-scenario-registration.js             # Script: registration flow (Phase 1 only)
├── run-scenario-admin-approve.js            # Script: admin approval flow (Phase 2 only)
├── run-scenario-e2e-registration-approval.js# Script: combined Phase 1 + Phase 2 + Phase 3
├── run-endtoend.js                          # Script: full end-to-end with counter
├── run-vendor-login-all.js                  # Script: all vendor app login scenarios
│
├── fixtures/                                # Test data, config & helper scripts
│   ├── credentials.yml                      # Environment URLs, credentials, OTPs
│   ├── run-counter.json                     # Auto-incrementing run counter for unique data
│   ├── upload-files.js                      # Upload files to all <input type=file> elements
│   ├── check-response.js                    # Intercept API responses for debugging
│   ├── check-errors.js                      # Detect & collect visible form error messages
│   ├── check-inputs.js                      # Inspect all input values inside the form drawer
│   ├── check-uploads.js                     # Inspect file upload areas & accepted types
│   ├── debug-button.js                      # Debug "next step" button state & retry click
│   ├── debug-drawer.js                      # Inspect drawer DOM structure & visibility
│   ├── debug-form.js                        # General form debugging helper
│   ├── expire-otp.js                        # Simulate OTP timer expiry (+10 min via Date.now override)
│   ├── fill-step1.js                        # Programmatically fill Step 1 form fields
│   ├── find-step2.js                        # Detect if Step 2 form has been reached
│   ├── fix-dropdowns.js                     # Force-open & select react-select dropdowns
│   ├── fix-store-type.js                    # Fix store type dropdown selection
│   ├── force-next.js                        # Force-click "next step" button
│   ├── force-submit.js                      # Force-submit form and capture request log
│   ├── select-city.js                       # Select city & district in Step 1 via react-select IDs
│   ├── test-uploads.js                      # Run negative upload tests (large file, invalid type)
│   ├── validate-step1.js                    # Validate Step 1 required fields before proceeding
│   ├── click-next-listen.js                 # Click next with request listener attached
│   ├── click-step2.js                       # Click into Step 2 and verify transition
│   ├── clickup-login.js                     # ClickUp integration login helper
│   ├── clickup-prd.json                     # ClickUp PRD reference data
│   ├── figma-file.json                      # Figma design reference
│   ├── figma-google-login.js                # Figma Google login helper
│   ├── figma-images.json                    # Figma image references
│   ├── figma-relevant-nodes.json            # Figma relevant node IDs
│   ├── figma/                               # Figma assets folder
│   └── uploads/                             # Test files for upload scenarios
│       ├── commercial-registration.jpg      # Valid CR document (JPG)
│       ├── commercial-registration.png      # Valid CR document (PNG)
│       ├── vat-certificate.jpg              # Valid VAT certificate (JPG)
│       ├── vat-certificate.png              # Valid VAT certificate (PNG)
│       ├── large-file.jpg                   # Oversized file (negative test)
│       ├── fake-image.exe                   # Invalid file type (negative test)
│       ├── test.bmp                         # BMP format (negative test)
│       └── test.svg                         # SVG format (negative test)
│
├── scenarios/                               # Gherkin BDD feature files
│   ├── Admin/
│   │   ├── app_login.feature               # Admin panel login scenarios
│   │   ├── endtoend.feature                # Full end-to-end scenario definitions
│   │   ├── register.feature                # Vendor registration scenarios
│   │   └── testRegisteration.feature       # Registration test variations
│   └── vendorApp/
│       └── login.feature                   # Vendor app login scenarios
│
├── prompts/                                 # Reusable AI agent prompts
│   ├── Execution.md                         # Scenario execution prompt
│   ├── Bug_Report.md                        # Bug report generation prompt
│   ├── Github_issue.md                      # GitHub issue publishing prompt
│   └── Project_Setup_Manual.md             # This manual
│
├── evidence/                                # Screenshot evidence (auto-created per run)
│   ├── register_successful_registration/
│   │   └── YYYY-MM-DD/
│   │       └── NNN-description.png
│   ├── app_login_admin/
│   │   └── YYYY-MM-DD/
│   │       └── NNN-description.png
│   ├── e2e_registration_approval/
│   │   └── YYYY-MM-DD/
│   │       └── NNN-description.png
│   ├── endtoend/
│   │   └── <ISO-timestamp>/
│   │       └── NNN-description.png
│   └── vendor_app_login/
│       └── YYYY-MM-DD/
│           └── NNN-description.png
│
└── bug_reports/                             # Generated markdown bug reports
    └── <scenario_name>/
        └── <bug-title>.md
```

### Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Feature files | `snake_case.feature` | `app_login.feature` |
| Run scripts | `run-<description>.js` | `run-scenario-registration.js` |
| Evidence root folders | `<scenario_tag_name>/` | `register_successful_registration/` |
| Evidence date subfolders | `YYYY-MM-DD/` or ISO timestamp | `2026-04-28/` |
| Screenshots | `NNN-description.png` | `001-login-page.png` |
| Bug reports | `kebab-case.md` | `registration-silent-login.md` |
| Fixtures | `kebab-case.js` or `.yml` | `check-response.js` |

---

## 5. Configuration Files

### `fixtures/credentials.yml`

This is the **single source of truth** for all environment URLs and test credentials.

```yaml
app:
  url: "https://app.development.qawafel.dev/home"
  mobile: "538989808"
  otp: "201111"

  Vendor_Store:
  mobile: "538989802"
  otp: "201111"

  admin:
  url: https://admin.development.qawafel.dev
  email: "ahmedwahba@qawafel.sa"
  password: "Ahmedwahba@123"
```

**Rules:**
- Never hardcode credentials directly in feature files or prompts
- The execution prompt reads this file automatically
- Always mask passwords in bug reports before publishing

### `fixtures/run-counter.json`

Tracks the auto-incrementing run counter used to generate unique test data per run:

```json
{
  "counter": 10
}
```

Each run script reads this counter to derive:
- **Mobile number** — `55698980<counter>` (e.g., `556989810`)
- **Email** — `test.reg.qawafel<counter>@example.com`
- **CR number** — `10000000<counter padded to 2 digits>` (10 digits)
- **VAT number** — `3001000000000<counter padded to 2 digits>` (15 digits)
- **Short address** — `TSTB<counter padded to 4 digits>` (e.g., `TSTB0010`)

The counter is incremented **only after a successful registration** to avoid wasting unique numbers on failed runs.

> **Important:** Do not manually edit this file while a run script is executing.

---

## 6. Run Scripts

The project contains five `run-*.js` scripts at the project root. All are executed via Node.js.

### `run-scenario-registration.js`

Executes **Phase 1** of the registration flow only.

```powershell
node run-scenario-registration.js
```

**What it does:**
1. Reads the current counter from `fixtures/run-counter.json`
2. Derives unique mobile, email, CR, VAT, and short-address values for the run
3. Launches a headed Chromium browser (locale: `ar-SA`, `slowMo: 100ms`)
4. Navigates to `https://store.development.qawafel.dev/hint`
5. Enters the mobile number and submits OTP `201111`
6. Fills **Step 1** (store info, contact info, address via react-select)
7. Fills **Step 2** (legal name, CR number, VAT number, uploads CR and VAT documents)
8. Submits the form and waits for the "pending" popup
9. Captures screenshots throughout in `evidence/register_successful_registration/YYYY-MM-DD/`
10. Increments the counter on success

**Key config inside the script:**
```javascript
const STORE_URL = 'https://store.development.qawafel.dev/hint';
const OTP       = '201111';
const STORE_AR  = 'مخبز الاختبار';   // Arabic store name (letters only — API rejects digits)
const STORE_EN  = 'Test Bakery';      // English store name
```

---

### `run-scenario-admin-approve.js`

Executes **Phase 2** only — admin logs in and approves a specific pending registration.

```powershell
node run-scenario-admin-approve.js
```

**What it does:**
1. Launches a headed Chromium browser
2. Navigates to `https://admin.development.qawafel.dev` and logs in with admin credentials
3. Navigates to the verification center: `/verification-center/list`
4. Searches for the pending mobile number (`556989802` by default — update as needed)
5. Opens the record and clicks "Verify Retailer"
6. Confirms the approval action
7. Captures screenshots in `evidence/app_login_admin/YYYY-MM-DD/`

**Precondition:** The target mobile must have already completed registration (Phase 1) and be in "pending" status.

> **To approve a different mobile:** Edit the `PENDING_MOBILE` constant at the top of the script before running.

---

### `run-scenario-e2e-registration-approval.js`

Executes the **full three-phase end-to-end flow** in a single run:
- **Phase 1** — Registration (vendor store)
- **Phase 2** — Admin approval (admin panel)
- **Phase 3** — Post-approval login verification (vendor app)

```powershell
node run-scenario-e2e-registration-approval.js
```

**What it does:**
1. Reads the run counter and generates unique test data
2. **Phase 1:** Completes the full registration flow on the vendor store
3. **Phase 2:** Opens a new browser context, logs into the admin panel, navigates to the verification center, and approves the just-registered mobile
4. **Phase 3:** Opens another browser context on the vendor app (`https://app.development.qawafel.dev`) and verifies the account status is "verified"
5. Increments the counter on full success
6. Saves all evidence to `evidence/e2e_registration_approval/YYYY-MM-DD/`

**This is the recommended script for full regression validation.**

---

### `run-endtoend.js`

An alternative end-to-end script with **ISO timestamp-based evidence folders** for precise run tracking.

```powershell
node run-endtoend.js
```

**Differences from `run-scenario-e2e-registration-approval.js`:**
- Evidence is saved in `evidence/endtoend/<ISO-timestamp>/` (e.g., `2026-04-28T14-30-00`)
- Uses a slightly different CR/VAT number generation strategy (timestamp-based instead of counter-based)
- Includes more extensive console log capture

---

### `run-vendor-login-all.js`

Runs all vendor app login scenarios — both positive and negative — in sequence.

```powershell
node run-vendor-login-all.js
```

**Scenarios covered:**

| # | Scenario | Expected |
|---|----------|----------|
| 1 | Valid credentials (registered & approved vendor) | Successful login |
| 2 | Unregistered mobile | Error shown |
| 3 | Registered but not yet approved | Error / restricted access |
| 4 | Empty mobile field | Validation error |
| 5 | Invalid mobile format (too short) | Validation error |
| 6 | Invalid mobile format (wrong prefix) | Validation error |

**Selectors used:**
```javascript
const SEL = {
  mobile:    "input[placeholder='5xxxxxxxxx']",
  loginBtn:  "button:has-text('تسجيل الدخول')",
  verifyBtn: "button:has-text('متابعة')",
  errorIndicators: '[class*=error], [class*=alert], [role=alert], .Toastify, [class*=toast], [class*=destructive]',
};
```

Evidence is saved per scenario to `evidence/vendor_app_login/YYYY-MM-DD/<NNN-description.png>`.

A final **results summary** is printed to the console at the end of the run.

---

## 7. Writing Feature Files

### Structure

Every `.feature` file follows this structure:

```gherkin
Feature: <Feature Name>
  As a <role>
  I want to <action>
  So that <benefit>

  Background:
    Given <shared preconditions>

  # ──────────────── Positive Scenarios ────────────────

  @tag1 @positive @smoke
  Scenario: <Descriptive name>
    When <action>
    Then <expected result>

  # ──────────────── Negative Scenarios ────────────────

  @tag1 @negative
  Scenario: <Descriptive name>
    When <invalid action>
    Then <error handling>

  # ──────────────── Failed Registration Scenarios ────────────────

  @tag1 @failed
  Scenario: <Descriptive name>
    Given <precondition>
    When <action that should fail>
    Then <failure behavior>
```

### Smart BDD Rules

1. **No click-by-click steps** — Use business-level language
2. **Unique test data per scenario** — Each scenario gets its own mobile number
3. **Group by category** — Positive, Negative, Failed sections with comment headers
4. **Tags** — `@feature @type @priority` (e.g., `@register @negative`)
5. **Arabic UI labels** — Quote exact UI text in double quotes
6. **Background** — Shared preconditions only, applied to ALL scenarios in the file

### Available Feature Files

| File | Scenarios |
|------|-----------|
| `scenarios/Admin/app_login.feature` | Admin panel login & vendor store access |
| `scenarios/Admin/register.feature` | Vendor B2B registration (positive, negative, failed) |
| `scenarios/Admin/endtoend.feature` | Full end-to-end registration + approval flow |
| `scenarios/Admin/testRegisteration.feature` | Registration test variations |
| `scenarios/vendorApp/login.feature` | Vendor app login (positive, negative) |

### Example: Complete Feature File

See `scenarios/Admin/register.feature` for a full reference with:
- 2 positive scenarios
- 3 negative scenarios
- 3 failed registration scenarios

---

## 8. Prompt Templates

The project uses **3 core prompts** stored in `prompts/`:

| Prompt | File | Purpose |
|--------|------|---------|
| Execution | `Execution.md` | Execute a Gherkin scenario step-by-step via Copilot agent |
| Bug Report | `Bug_Report.md` | Generate a structured bug report from execution failures |
| GitHub Issue | `Github_issue.md` | Publish a bug report as a GitHub issue via `gh` CLI |

### Usage Flow

```
1. Paste Execution.md prompt → provide scenario file path
2. Agent executes scenario, captures evidence
3. If failed → paste Bug_Report.md prompt → agent generates report
4. To publish → paste Github_issue.md prompt → provide repo + report path
```

---

## 9. Execution Workflow

### Option A: Run a script directly (recommended)

```powershell
# Registration flow only
node run-scenario-registration.js

# Admin approval flow only (update PENDING_MOBILE in the script first)
node run-scenario-admin-approve.js

# Full end-to-end (registration + approval + verification)
node run-scenario-e2e-registration-approval.js

# End-to-end with ISO timestamp folders
node run-endtoend.js

# All vendor app login scenarios
node run-vendor-login-all.js
```

Each script:
- Prints run data (counter, mobile, email, CR, VAT, short address) to the console
- Opens a headed Chromium browser (visible window) in `ar-SA` locale
- Saves screenshots to the corresponding `evidence/` subfolder
- Prints a pass/fail summary at the end

### Option B: AI-assisted execution via Copilot

**Step 1:** Open VS Code Copilot Chat and paste the contents of `prompts/Execution.md`.

**Step 2:** Tell the agent which scenario to execute:
```
Execute the scenario in: scenarios/Admin/register.feature
```

**Step 3:** The agent will:
1. Read `fixtures/credentials.yml` for URLs and credentials
2. Open a headed Chromium browser
3. Follow the scenario steps using Playwright
4. Capture screenshots at each meaningful step
5. Store evidence in `evidence/<scenario_name>/<date>/`
6. Provide a pass/fail summary at the end

**Step 4:** Review evidence screenshots and the agent summary.

---

## 10. Evidence Collection

Evidence is stored automatically during script execution:

```
evidence/
├── register_successful_registration/
│   └── YYYY-MM-DD/
│       ├── 001-store-hint-page.png
│       ├── 002-mobile-entered.png
│       ├── 003-otp-screen.png
│       └── ...
├── app_login_admin/
│   └── YYYY-MM-DD/
│       ├── 001-admin-login-page.png
│       └── ...
├── e2e_registration_approval/
│   └── YYYY-MM-DD/
│       └── NNN-description.png
├── endtoend/
│   └── <ISO-timestamp>/
│       └── NNN-description.png
└── vendor_app_login/
    └── YYYY-MM-DD/
        └── NNN-description.png
```

**Screenshot Rules:**
- Three-digit numeric prefix for strict ordering (e.g., `001`, `002`)
- Short kebab-case description suffix (e.g., `otp-entered`, `step2-form`)
- `fullPage: false` by default (viewport only) — use `fullPage: true` for vendor login scenarios
- Evidence is preserved even on failure (captures the failure state for debugging)
- One folder per script execution per date (or per ISO timestamp for `run-endtoend.js`)

---

## 11. Bug Reporting

When a scenario fails, generate a structured bug report.

### Steps:
1. Paste `prompts/Bug_Report.md` into the Copilot agent session
2. The agent reads the execution summary, evidence screenshots, and original scenario
3. A structured Markdown bug report is generated in `bug_reports/<scenario_name>/`

### Bug Report Structure:
- **Title** — concise, describes the defect
- **Environment** — dev URL, browser, OS
- **Severity** — Critical / High / Medium / Low
- **Preconditions** — what must be set up before reproducing
- **Steps to Reproduce** — numbered, specific steps
- **Expected Result** — what should happen
- **Actual Result** — what actually happened
- **Evidence** — screenshot paths
- **Console Errors** — any browser console errors captured
- **Additional Notes** — workarounds, related issues

---

## 12. GitHub Issue Publishing

### Steps:
1. Paste `prompts/Github_issue.md` into the agent session
2. Provide: repository name, issue title, and bug report file path
3. The agent runs `gh issue create --body-file <path>`
4. The created issue URL is returned

### Example:
```powershell
gh issue create `
  --repo "qawafel/quality-onboarding" `
  --title "[Registration] Silent login on existing mobile" `
  --body-file "bug_reports/register_already_registered_mobile/registration-silent-login.md"
```

---

## 13. Fixtures & Helper Scripts

All fixture scripts export an `async (page) => {}` function and are designed to be injected into an active Playwright page object during debugging or investigation.

### Form Filling

#### `fixtures/fill-step1.js`
Programmatically fills all Step 1 registration fields (store name Arabic/English, store type dropdown, first/last name, email, mobile, national address).

#### `fixtures/select-city.js`
Selects city and district in Step 1 using the exact react-select input IDs (`#react-select-5-input`, `#react-select-6-input`). Types the city name and presses Enter to confirm.

#### `fixtures/fix-dropdowns.js`
Force-opens react-select dropdowns by finding all `[class*="control"]` elements and clicking the nth one. Used when normal Playwright click is blocked.

#### `fixtures/fix-store-type.js`
Specifically targets the store type react-select (`react-select-3-input`) and selects the first available option.

### File Uploads

#### `fixtures/upload-files.js`
Uploads `fixtures/uploads/commercial-registration.jpg` to all visible `<input type="file">` elements on the page:
```javascript
async (page) => {
  const inputs = await page.locator('input[type=file]').all();
  const filePath = 'fixtures/uploads/commercial-registration.jpg';
  for (const input of inputs) {
    await input.setInputFiles(filePath);
  }
}
```

#### `fixtures/test-uploads.js`
Runs negative upload tests: uploads `large-file.jpg` (oversized) and `fake-image.exe` (invalid type), checks for error messages, and removes files if accepted unexpectedly.

#### `fixtures/check-uploads.js`
Inspects all file upload areas: counts `<input type="file">` elements, checks accepted formats, and lists upload labels visible in the DOM.

### Debugging

#### `fixtures/check-errors.js`
Collects all visible form validation errors (`[class*="text-red"]`, `.text-destructive`) and checks if Step 2 content is present. Retries clicking the "next step" button and compares errors before/after.

#### `fixtures/check-inputs.js`
Scrolls to the top of the form drawer, then reads all visible input values (type, name, placeholder, value) and all react-select `singleValue` selections.

#### `fixtures/check-response.js`
Intercepts API responses during form submission:
```javascript
async (page) => {
  const handler = async (response) => {
    const url = response.url();
    if (url.includes('customers/register') || url.includes('customers/addresses')) {
      console.log(url, await response.json());
    }
  };
  page.on('response', handler);
}
```

#### `fixtures/debug-button.js`
Inspects the "next step" button (`الخطوة التالية`) — reports disabled state, visibility, bounding rect, z-index, pointer-events, and parent form action. Attempts a retry click.

#### `fixtures/debug-drawer.js`
Reads the inner HTML structure of the registration drawer, checks form children visibility, and reports whether Step 2 content (legal name, CR number fields) is present.

#### `fixtures/debug-form.js`
General form debugging helper — checks overall form state, visible fields, and scroll position.

### OTP & Navigation

#### `fixtures/expire-otp.js`
Overrides `Date.now` in the browser context to simulate OTP timer expiry (+10 minutes). Use to test the "OTP expired" scenario:
```javascript
async (page) => {
  await page.evaluate(() => {
    const real = Date.now.bind(Date);
    Date.now = () => real() + 10 * 60 * 1000;
  });
}
```

#### `fixtures/force-next.js`
Force-clicks the "next step" button using `{ force: true }` to bypass pointer-events blocking.

#### `fixtures/force-submit.js`
Attaches a request listener, then force-clicks the next step button and logs all POST/API requests captured during the subsequent 5 seconds.

#### `fixtures/click-next-listen.js`
Clicks the next step button with an active request listener to correlate the click with API calls.

#### `fixtures/click-step2.js`
Clicks into Step 2 and verifies that the transition from Step 1 to Step 2 has occurred.

#### `fixtures/find-step2.js`
Checks the DOM for Step 2 indicators (`المعلومات القانونية`, `السجل التجاري`) without clicking anything.

#### `fixtures/validate-step1.js`
Validates that all required Step 1 fields are filled before attempting to proceed.

### Adding New Fixtures

1. Create a new `.js` file in `fixtures/` named in `kebab-case`
2. Export a single `async (page) => {}` function
3. Inject it during a Playwright session via the `page.evaluate()` pattern or agent execution
4. Place any required test files in `fixtures/uploads/`

---

## 14. Complete Prompt Reference

Below are all prompts used in this project.

---

### Prompt 1: Scenario Generation

```markdown
# Scenario Generation Prompt

You are helping me create Gherkin BDD scenarios for a Qawafel application feature.

Before doing anything else:

1. Read `fixtures/credentials.yml` for available environment URLs, mobile numbers, and OTP values.
2. If a feature file already exists at the path I provide, read it first to understand existing scenarios.

I will give you:
- The feature name and description
- The application area (Admin app or Vendor Store)
- The user role
- The positive flows to cover
- The negative/edge cases to cover

Follow these rules strictly:

1. Use **smart BDD style** — business-level steps, NOT click-by-click UI actions.
2. Group scenarios by category with comment headers:
   - `# ──────────────── Positive Scenarios ────────────────`
   - `# ──────────────── Negative Scenarios ────────────────`
   - `# ──────────────── Failed Scenarios ────────────────`
3. Use **unique test data per scenario** — each scenario must have its own mobile number.
4. Use tags: `@feature @type @priority` (e.g., `@login @negative`).
5. Quote Arabic UI labels exactly in double quotes.
6. Use Background for shared preconditions applied to ALL scenarios.
7. Include the Feature header with As a / I want / So that.
8. Limit negative scenarios to **3 max** — pick the most impactful cases.
9. Every scenario name must be **descriptive and unique** within the file.
10. Do not add step definitions or automation code — these are for manual execution.

Output format: A complete `.feature` file ready to save.
```

---

### Prompt 2: Scenario Execution

*(See `prompts/Execution.md` and Section 9 above for full details)*

---

### Prompt 3: Bug Report Generation

*(See `prompts/Bug_Report.md` and Section 11 above for full details)*

---

### Prompt 4: GitHub Issue Publishing

*(See `prompts/Github_issue.md` and Section 12 above for full details)*

---

### Prompt 5: Feature File Grooming

```markdown
# Feature File Grooming Prompt

You are helping me groom and refine an existing Gherkin feature file.

Before doing anything else:

1. Read the feature file I provide.
2. Read `fixtures/credentials.yml` for available test data.
3. Review any execution evidence in `evidence/` related to this feature.

I want you to review and improve the feature file following these rules:

1. Ensure all scenarios use **unique mobile numbers** — no two scenarios share the same test data.
2. Group scenarios by category with comment section headers (Positive, Negative, Failed).
3. Apply proper tags: `@feature @type` on each scenario.
4. Remove redundant or overlapping negative scenarios — keep max 3 of the most impactful.
5. Ensure steps use **business-level language**, not click-by-click instructions.
6. Verify the Background section contains only truly shared preconditions.
7. Check that all Arabic UI labels are quoted correctly.
8. Ensure scenario names are descriptive and unique.
9. Add any missing edge cases you identify (max 2 suggestions).
10. Present the changes as a diff summary, then provide the complete updated file.

Do NOT:
- Change passing scenario logic
- Add automation code
- Remove scenarios without explaining why
```

---

### Prompt 6: Test Data Management

```markdown
# Test Data Management Prompt

You are helping me manage test data for the Qawafel BDD test project.

Before doing anything else:

1. Read `fixtures/credentials.yml` for current test data.
2. Read `fixtures/run-counter.json` for the current counter value.
3. Read all `.feature` files in `scenarios/` to find all mobile numbers and test data in use.

Produce:

1. **Test Data Registry** — A table listing every mobile number used, which scenario uses it, and its purpose.
2. **Conflict Check** — Flag any duplicate mobile numbers used across different scenarios.
3. **Available Range** — Suggest the next available mobile numbers following the `55698980<N>` pattern.
4. **Counter Alignment** — Verify the run counter in `run-counter.json` is consistent with the highest mobile number seen in evidence folders.
5. **Credentials File Update** — If any credentials used during execution are missing from `credentials.yml`, suggest additions.

Rules:
- Scan ALL feature files recursively
- Include credentials from both `credentials.yml` and inline scenario data
- Flag any hardcoded credentials that should be moved to `credentials.yml`
```

---

### Prompt 7: Execution Summary Report

```markdown
# Execution Summary Prompt

You are helping me generate a consolidated execution summary for a test run.

Before doing anything else:

1. Read all feature files in `scenarios/`.
2. Scan the `evidence/` folder to determine which scenarios have been executed and when.
3. Read any bug reports in `bug_reports/`.

Produce a **Test Execution Report** with:

### 1. Execution Summary Table

| # | Feature | Scenario | Status | Evidence | Bug Report |
|---|---------|----------|--------|----------|------------|
| 1 | Register | Successful registration | ✅ PASS | evidence/register_successful_registration/ | — |
| 2 | Admin | Admin approval | ✅ PASS | evidence/app_login_admin/ | — |
| 3 | E2E | Full registration + approval | ❌ FAIL | evidence/e2e_registration_approval/ | bug_reports/... |

### 2. Statistics
- Total scenarios: X | Passed: X | Failed: X | Not executed: X | Pass rate: X%

### 3. Defects Found
List each bug report with title, severity, and GitHub issue link (if published).

### 4. Recommendations
- Scenarios that need re-testing
- Missing test coverage areas
- Test data issues

Rules:
- Base pass/fail status on evidence existence and bug reports only — do not guess
- List unexecuted scenarios separately
```
