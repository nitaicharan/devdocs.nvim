local make_logged = require("devdocs.application.helpers.make_logged")

local M = {}

---@param html string
---@return string
M.html_to_markdown = function(html)
  assert(type(html) == "string", "html must be a string")

  local transpile_command = {
    "pandoc",
    "--from", "html",
    "--to", "gfm-raw_html",
    "--wrap", "none",
  }

  return vim.fn.system(transpile_command, tostring(html))
end

---@param html string
---@param on_success fun(markdown: string)
M.html_to_markdown_async = function(html, on_success)
  assert(type(html) == "string", "html must be a string")
  assert(type(on_success) == "function", "on_success must be a function")

  local transpile_command = {
    "pandoc",
    "--from", "html",
    "--to", "gfm-raw_html",
    "--wrap", "none",
  }

  vim.system(transpile_command, { stdin = html }, vim.schedule_wrap(function(result)
    on_success(result.stdout)
  end))
end

return make_logged("external/clients/pandas_client", M)
