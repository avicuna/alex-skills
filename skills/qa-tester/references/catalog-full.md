# Full QA Mode: Feature Catalog

Systematically explore the codebase to identify all testable surfaces. Use Glob and Grep directly for focused searches.

#### Step 1: Discover Routes and Pages

Search for route definitions based on the detected framework:

| Framework | Search Locations |
|-----------|-----------------|
| SvelteKit | `src/routes/**/+page.svelte`, `src/routes/**/+server.ts` |
| Next.js (App Router) | `app/**/page.tsx`, `app/**/route.ts` |
| Next.js (Pages Router) | `pages/**/*.tsx` (exclude `_app`, `_document`) |
| React Router | Grep for `createBrowserRouter`, `<Route`, `<Routes` |
| Vue/Nuxt | `pages/**/*.vue`, `components/**/*.vue` |
| Go CLI | `cmd/*/main.go`, subcommands in `internal/` or `pkg/` |
| Express/Fastify | Grep for `app.get`, `app.post`, `app.put`, `app.delete`, `router.` |

#### Step 2: Discover Interactive Components

Search for components with user interaction:

- **Forms**: Grep for `<form`, `onSubmit`, `handleSubmit`, `useForm`, `v-model`
- **Modals/Dialogs**: Grep for `dialog`, `modal`, `Dialog`, `Modal`, `Sheet`, `Drawer`
- **Dropdowns/Selects**: Grep for `<select`, `Combobox`, `Dropdown`, `Popover`
- **Buttons with handlers**: Grep for `onClick`, `on:click`, `@click`, `hx-post`
- **File uploads**: Grep for `type="file"`, `dropzone`, `upload`

#### Step 3: Discover State Management

- **Svelte**: Look in `src/lib/stores/` for `.ts` files, grep for `writable`, `readable`, `derived`
- **React**: Grep for `createContext`, `useReducer`, `zustand`, `createSlice` (Redux Toolkit), `atom` (Jotai/Recoil)
- **Vue**: Look in `composables/`, `stores/`, grep for `defineStore` (Pinia), `ref(`, `reactive(`
- **Go**: Check for config files, environment variable parsing, flag definitions

#### Step 4: Discover External Integrations

- Grep for `fetch(`, `axios`, `$fetch`, HTTP client usage
- Look for WebSocket connections: `WebSocket`, `socket.io`, `ws`
- Look for database access: `prisma`, `drizzle`, `sql`, `query`, `db.`
- Look for third-party SDK usage: payment processors, auth providers, storage services

#### Step 5: Discover Settings and Configuration Surfaces

- Look for settings/preferences pages or components
- Look for admin panels or dashboards
- Check for feature flags, environment-driven behavior, config files users interact with

#### Step 6: Compile and Present Catalog

Organize findings into a numbered feature catalog. Estimate test count per area based on:
- Number of routes/pages in the area: ~2-3 tests per page
- Number of interactive components: ~1-2 tests per component
- Number of state flows: ~2-4 tests per distinct flow
- Number of integrations: ~2-3 tests per external dependency

Present to the user in this format:

```
## Feature Catalog

1. **<Feature Area>** (~N tests) — brief description of surfaces
2. **<Feature Area>** (~N tests) — brief description of surfaces
3. ...

Reply with the numbers of any areas to skip, or describe what to add.
```

Wait for user response. Apply their edits (removals, additions, reprioritization) and confirm the final catalog before proceeding to Phase 2.
