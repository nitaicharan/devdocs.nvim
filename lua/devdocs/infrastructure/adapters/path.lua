---@class IPathAdapter
---@field stdpath fun(what: string): string

---@type IPathAdapter
return {
  stdpath = function(what)
    return vim.fn.stdpath(what) --[[@as string]]
  end,
}
