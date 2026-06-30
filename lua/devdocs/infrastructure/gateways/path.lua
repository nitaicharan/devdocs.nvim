return {
  ---@param what string
  ---@return string
  stdpath = function(what)
    return vim.fn.stdpath(what) --[[@as string]]
  end,
}
