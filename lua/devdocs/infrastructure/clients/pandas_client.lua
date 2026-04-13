---@class IPandasClient
---@field html_to_markdown fun(html: string): string
---@field html_to_markdown_async fun(html: string, on_success: fun(markdown: string))

local make_logged_helper = require("devdocs.application.helpers.make_logged")
local make_logged = make_logged_helper.make_logged

---@type IPandasClient
return make_logged("pandas_client", {
  html_to_markdown = function(html)
    assert(type(html) == "string", "html must be a string")

    local transpile_command = {
      "pandoc",
      "--from", "html",
      "--to", "gfm-raw_html",
      "--wrap", "none",
    }

    return vim.fn.system(transpile_command, tostring(html))
  end,

  html_to_markdown_async = function(html, on_success)
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
  end,
})
