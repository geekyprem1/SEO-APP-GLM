# Speed optimization (no minInstances)

**Status:** Done (deployed)  
**Goal:** Faster Generate feel without always-on warm instances.

## Changes

1. **Warmup ping** — `generateContent` accepts `{ warmup: true }`, auth only, no AI/quota.
2. **Client** — after login / MainShell open, fire-and-forget warmup (non-blocking).
3. **Parallel prechecks** — rate limit, quota, budget, cache in `Promise.all`.
4. **Parallel post-AI writes** — cache, usage, cost, log together (safe; no lost quota).

## Out of scope

- `minInstances`
- Region migrate to Mumbai
- Model changes
