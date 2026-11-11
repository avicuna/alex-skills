# Recipe: Web App Testing (Playwright MCP)

Use this recipe when testing web applications, SPAs, SSR apps, or any browser-accessible interface.

#### Available Tools

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Go to app URL |
| `browser_snapshot` | Get accessibility tree — **PRIMARY assertion method** (preferred over screenshots) |
| `browser_click` | Interact with buttons, links, tabs, checkboxes |
| `browser_type` | Fill a single text input |
| `browser_fill_form` | Fill multiple form fields at once |
| `browser_evaluate` | Run JS assertions (check console errors, DOM state, store values, localStorage) |
| `browser_console_messages` | Check for runtime errors after each interaction |
| `browser_take_screenshot` | Capture visual evidence of bugs — NOT for assertions |
| `browser_press_key` | Keyboard shortcuts, Tab navigation, Enter to submit, Escape to close |
| `browser_select_option` | Select dropdown options |
| `browser_wait_for` | Wait for async operations to complete (text appearing, text disappearing, or fixed delay) |
| `browser_hover` | Trigger hover states (tooltips, dropdown menus, previews) |
| `browser_drag` | Drag-and-drop interactions |

#### Assertion Patterns

- **Verify text appears:** Use `browser_snapshot` and check the accessibility tree for the expected text or element role.
- **Verify an element is gone:** Use `browser_snapshot` and confirm the element/text is absent from the tree.
- **Check for JS errors:** Use `browser_console_messages` with level `error` after each major interaction. Any unexpected error is a test failure.
- **Check DOM state:** Use `browser_evaluate` with a JS function that returns the value to assert (e.g., `() => document.querySelector('.counter').textContent`).
- **Check localStorage/sessionStorage:** Use `browser_evaluate` with `() => JSON.parse(localStorage.getItem('key'))`.
- **Test keyboard navigation:** Use `browser_press_key` with Tab, Enter, Escape, ArrowDown, ArrowUp. Then `browser_snapshot` to confirm focus moved correctly.
- **Verify visual state (color, visibility, size):** Use `browser_evaluate` with `getComputedStyle()` — do NOT rely on screenshots for assertions.
- **Verify navigation occurred:** After a click, use `browser_evaluate` with `() => window.location.pathname` or check the snapshot for new page content.

#### Example: Single Test Execution

Test: `T1.2.3 — Submit form with valid data shows success message`

```
1. browser_navigate → app URL + "/contact"
2. browser_snapshot → confirm form is present (look for form role, input fields)
3. browser_fill_form → fill Name, Email, Message fields
4. browser_click → click Submit button (ref from snapshot)
5. browser_wait_for → wait for "Message sent" text to appear
6. browser_snapshot → confirm success message is visible, form is cleared or hidden
7. browser_console_messages (level: error) → confirm no JS errors fired
```

Result: If success message found in snapshot and no console errors → `PASS`. If success message missing or JS error present → `FAIL` + capture screenshot as evidence.

#### Web Testing Flow

1. Start by navigating to the app base URL. Confirm it loads (snapshot shows expected content).
2. For each test section, navigate to the relevant page/route.
3. Execute tests sequentially within a section (they may share state like a logged-in session).
4. Between sections: `browser_evaluate` with `() => { localStorage.clear(); sessionStorage.clear(); document.cookie.split(';').forEach(c => document.cookie = c.trim().split('=')[0] + '=;expires=Thu, 01 Jan 1970'); }` then navigate to base URL.
5. If a test requires login, perform login as a setup step (not counted as a test) before the section.

#### Error Evidence Collection (Web)

On any `FAIL`:
1. `browser_take_screenshot` — capture the current visual state
2. `browser_console_messages` (level: error) — capture any JS errors
3. `browser_evaluate` with `() => window.location.href` — record current URL
4. Note the expected vs actual in the result log
