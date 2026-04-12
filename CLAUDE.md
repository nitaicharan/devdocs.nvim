# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

devdocs.nvim is a Neovim plugin that brings DevDocs.io documentation into Neovim with offline support, picker-based search, and markdown rendering. It fetches documentation from devdocs.io, converts HTML to Markdown via pandoc, and stores it locally.

## Running Tests

```bash
# All tests
nvim -l tests/minit.lua --minitest

# Specific test files
nvim -l tests/minit.lua --minitest tests/usecases/*_spec.lua
```

Tests use lazy.minit with minitest runner, `describe`/`it` blocks and `luassert`.

## Linting and Formatting

```bash
selene lua/       # Lint (config: selene.toml, std=vim)
stylua lua/       # Format (config: .stylua.toml, 2-space indent, 100 col width)
```

## Architecture

The plugin follows **Clean Architecture** with unidirectional dependency flow:

```
UI (presentation) → Usecase (orchestration) → Request/Repository (data) → Client/Adapter (external)
```

### Layer Breakdown

All source code lives under `lua/devdocs/`:

- **`domain/`** — Models (`---@class` annotated data types) and default configuration. No dependencies on other layers.
- **`application/usecases/`** — Business logic orchestrators. Each usecase coordinates requests and repositories to fulfill an operation (install, show, list, etc.). Also contains `application/types/` for repository interface definitions.
- **`infrastructure/`** — Everything with external dependencies:
  - `requests/` — HTTP calls to devdocs.io APIs via `plenary.curl`
  - `repositories/` — JSON file persistence in `vim.fn.stdpath("data")/devdocs/`
  - `clients/` — External tool wrappers (HTTP client, pandoc client)
  - `adapters/` — Transform API responses into domain models
  - `pickers/` — Selection UI (currently Snacks.nvim)
  - `uis/` — UI controllers that wire usecases to pickers and handle user interaction
  - `apis/` — Public API surface exposed via `require("devdocs").api`

### Entry Point

`lua/devdocs/init.lua` returns `{ setup, ui, api }`. The `setup()` function initializes the plugin by calling `lifecycle_usecase.on_plugin_init()` with injected dependencies (registries_request, registries_repository).

### Key Data Flow (e.g., installing docs)

1. UI controller receives user command (`:DevdocsInstall`)
2. Usecase orchestrates: fetch registry → show picker → fetch docs → convert HTML via pandoc → save to disk
3. Repositories handle JSON file I/O; requests handle HTTP; adapters transform responses

## Code Conventions

- **Module pattern**: Each file returns a table of functions (`return { fn_name = function(...) end }`). No metatable-based classes.
- **Dependency injection**: Usecases receive repositories and requests as function parameters rather than importing them directly.
- **Type annotations**: LuaCATS-style (`---@class`, `---@param`, `---@field`, `---@return`) throughout.
- **Param validation**: Uses `assert()` at function entry points for required parameters.
- **Async**: Background work uses `vim.schedule_wrap()` for Neovim event loop integration.
- **Interface contracts**: Repository interfaces defined in `application/types/` using `---@class` with `---@field` function signatures.

## Documentation

- **Design specs** go in `docs/superpowers/specs/` with naming `YYYY-MM-DD-<topic>-design.md`
- **Implementation plans** go in `docs/superpowers/plans/` with naming `YYYY-MM-DD-<topic>-plan.md`
- After exiting plan mode, always copy the plan file to `docs/superpowers/plans/`

## External Dependencies

- **plenary.nvim** — HTTP client (`plenary.curl`), path utilities, test framework
- **snacks.nvim** — Selection picker UI
- **pandoc** (system binary) — HTML to Markdown conversion (`pandoc --from html --to gfm-raw_html --wrap none`)
- **glow** (optional system binary) — Markdown preview rendering
