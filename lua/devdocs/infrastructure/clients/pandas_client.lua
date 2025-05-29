---@class IPandasClient
---@field html_to_markdown fun(html: string): string

---@type IPandasClient
return {
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
}
