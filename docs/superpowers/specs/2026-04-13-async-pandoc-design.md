# Async Pandoc Conversion — Design Spec

## Context

The previous async work (HTTP fetching) is done and committed. However, `:DevdocsInstall` still blocks Neovim because `documentations_repository.save()` calls `pandas_client.html_to_markdown()` (which uses `vim.fn.system("pandoc ...")`) synchronously in a loop — once per document page. Large doc sets (e.g., JavaScript) have hundreds of pages, each spawning a blocking pandoc process.

## Problem

`repository.save(documentation, registry.slug)` runs inside a `vim.schedule_wrap` callback (on the main Neovim thread). The `for slug, document in pairs(documentation)` loop calls `vim.fn.system()` per page, blocking the UI until all conversions complete.

## Design

**Approach:** Sequential async — convert pages one at a time using `vim.system()` (Neovim 0.10+, async subprocess API). Neovim stays responsive between conversions. Simple, no concurrency management needed.

### Components

**1. `pandas_client.html_to_markdown_async(html, on_success)`**
- Spawns pandoc via `vim.system()` with stdin input and `on_exit` callback
- Collects stdout, calls `on_success(markdown)` when process exits
- `vim.system()` callback runs on the main thread (no `vim.schedule_wrap` needed)

**2. `documentations_repository.save_async(documentation, id, on_done)`**
- Converts `pairs(documentation)` to an indexed list for sequential iteration
- Processes pages one at a time: convert page N async → write file → convert page N+1 → ... → call `on_done()`
- Uses a recursive `process_next()` pattern to chain async steps
- File writes (`file_util.write`) stay synchronous (fast, runs on main thread between async steps)

**3. `documentations_usecase` callback**
- Replace `repository.save(documentation, registry.slug)` with `repository.save_async(documentation, registry.slug, function() ... end)`
- The rest of the chain (entries install, lock save) moves inside the `on_done` callback

### Interface changes

```
pandas_client:
  + html_to_markdown_async(html: string, on_success: fun(markdown: string))

documentations_repository:
  + save_async(documentation: table<string,string>, id: string, on_done: fun())

documentations_usecase:
  (no interface change — internal callback body updated)
```

### Error handling

- If pandoc fails (non-zero exit), log error and stop processing remaining pages (same as current `xpcall` behavior that returns early on failure)
- `on_done` is NOT called on error (matches current behavior where sync save returns early)

### Testing

- `pandas_client` tests mock `vim.system` to invoke the `on_exit` callback synchronously
- Repository tests mock `pandas_client.html_to_markdown_async` to invoke callback synchronously
- Usecase tests mock `repository.save_async` to invoke `on_done` synchronously
- All tests remain synchronous — no async test infrastructure needed

### Minimum Neovim version

0.10+ (required for `vim.system()`)
