---
name: "playwright-cli"
description: "Browser automation skill using playwright-cli for headed Chromium testing against Qawafel development environments."
applyTo: "**/*.feature"
---

# playwright-cli Skill

## Overview

`playwright-cli` is a headed browser automation tool used for manual BDD scenario execution. It launches a visible Chromium browser and provides commands to interact with web pages, capture screenshots, and run JavaScript on the page.

## Available Commands

### `open <url>`
Opens a URL in a new headed Chromium browser session.
```powershell
playwright-cli open https://app.development.qawafel.dev/home
```

### `goto <url>`
Navigates the current browser tab to a new URL.
```powershell
playwright-cli goto https://store.development.qawafel.dev/hint
```

### `click <selector>`
Clicks an element matching the CSS selector or text content.
```powershell
playwright-cli click "text=دخول / تسجيل"
playwright-cli click "button:has-text('أنشئ الحساب')"
playwright-cli click "[data-testid='login-button']"
```

### `fill <selector> <value>`
Types a value into an input field.
```powershell
playwright-cli fill "input[type='tel']" "538989808"
playwright-cli fill "#otp-input" "201111"
```

### `screenshot <path>`
Captures a screenshot of the current page state.
```powershell
playwright-cli screenshot "evidence/app_login_admin/2026-04-21/001-login-page.png"
```
**Naming convention:** `NNN-description.png` (three-digit prefix, hyphenated description).

### `snapshot`
Returns the current page's accessibility tree / DOM snapshot for inspection. Useful for finding selectors and verifying page state.
```powershell
playwright-cli snapshot
```

### `eval <javascript>`
Executes JavaScript in the browser page context. Returns the result.
```powershell
playwright-cli eval "document.title"
playwright-cli eval "document.querySelector('.user-name')?.textContent"
```

### `run-code <file>`
Executes a JavaScript file against the current page. The file must export an `async (page) => {}` function.
```powershell
playwright-cli run-code fixtures/upload-files.js
playwright-cli run-code fixtures/expire-otp.js
playwright-cli run-code fixtures/check-response.js
```

### `tab-select <index>`
Switches to a specific browser tab by index (0-based).
```powershell
playwright-cli tab-select 1
```

## Interaction Patterns

### React-Select Dropdowns
Standard `click` won't work on React-Select components. Use `eval` to interact:
```powershell
playwright-cli eval "document.getElementById('react-select-3-input').closest('.css-1s2u09g-control').click()"
playwright-cli eval "Array.from(document.querySelectorAll('[id*=option]')).find(el => el.textContent.includes('target text')).click()"
```

### File Uploads
Use `run-code` with a helper script that calls `setInputFiles`:
```javascript
// fixtures/upload-files.js
async (page) => {
  const inputs = await page.locator('input[type=file]').all();
  for (const input of inputs) {
    await input.setInputFiles('fixtures/uploads/commercial-registration.jpg');
  }
}
```

### OTP Timer Simulation
Override `Date.now` to fast-forward timers:
```powershell
playwright-cli run-code fixtures/expire-otp.js
```

### API Response Interception
Attach a response listener before triggering an action:
```powershell
playwright-cli run-code fixtures/check-response.js
```

## Evidence Capture Rules

1. Store screenshots in `evidence/<scenario_name>/<YYYY-MM-DD>/`
2. Create the evidence directory before capturing: `New-Item -ItemType Directory -Force -Path "evidence/<path>"`
3. Capture a screenshot **after every meaningful step**
4. Use numbered filenames: `001-login-page.png`, `002-otp-entered.png`
5. Always capture the failure state if a scenario fails

## Browser Session Notes

- The browser runs in **headed mode** — always visible to the user
- The browser session persists across commands within the same terminal
- Use `tab-select` when actions open new tabs (e.g., store preview)
- Popups/modals may appear on first load — dismiss them before proceeding
- Arabic RTL layout: elements may be mirrored compared to LTR expectations

## Common Selectors (Qawafel)

| Element | Selector |
|---------|----------|
| Mobile input | `input[type='tel']` |
| OTP inputs | `input[type='tel']` (multiple, one per digit) |
| Login button | `button:has-text('دخول')` |
| Register button | `button:has-text('أنشئ الحساب')` |
| Sidebar menu | `.sidebar-menu` or `text=الإدارة` |
| User profile name | `.header .user-name` or snapshot to locate |

## Gherkin Scenario Standards

This project follows strict Gherkin standards to ensure scenarios are clear, atomic, and executable.

### Gherkin Style Guide (Summary)
1. **Write Behaviour, Not Implementation**: Focus on "what" happens, not "how" (avoid click-by-click instructions like "click button").
2. **Explicit Preconditions**: Use `Background` for shared setup and `Given` for state.
3. **Atomic Scenarios**: One coherent behaviour per scenario. Keep scenarios under 10 steps.
4. **Observable Outcomes**: Use visible UI changes (toasts, redirects, status changes) in `Then` steps.
5. **Data Richness**: Use Data Tables for structured input like forms.
6. **Independence**: Scenarios should set up their own state or explicitly link to prerequisites.

### Review Rubric
| Gate | Requirement |
| :--- | :--- |
| **Clear Start** | Explicit context, state, and prerequisites. |
| **Clear Actions** | Unambiguous and easy to follow. |
| **Clear Outcomes** | Observable success/failure metrics reachable via browser snapshots. |
| **Contained Scope** | One coherent behaviour per scenario. |

### Anti-patterns to Avoid
- **Vague outcomes**: e.g., "Then it works".
- **Implementation leakage**: Using CSS selectors or hardcoded waits in scenario text.
- **Enormous scenarios**: 10+ steps are likely mixing multiple behaviours.

---
*Refer to [gherkin/style-guide.md](gherkin/style-guide.md) and [gherkin/rubric.md](gherkin/rubric.md) for full specifications.*
