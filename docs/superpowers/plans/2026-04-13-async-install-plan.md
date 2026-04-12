# Async Documentation Installation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make documentation installation non-blocking so Neovim doesn't freeze during HTTP fetch + processing.

**Architecture:** Add `get_async` to http_client using plenary.curl's callback support. Add `find_async`/`list_async` to request modules that wrap the callback in `vim.schedule_wrap`. Switch the usecase install callback from sync to async chaining. Tests stay synchronous by mocking async methods to invoke callbacks immediately.

**Tech Stack:** plenary.curl (callback mode), vim.schedule_wrap

---

See full plan at: `.claude/plans/idempotent-mapping-trinket.md`
