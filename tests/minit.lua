#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"

load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"), "bootstrap.lua")()

require("lazy.minit").setup({
  spec = {
    { dir = vim.uv.cwd() },
    {
      "echasnovski/mini.test",
      opts = {
        collect = {
          -- Specs live next to the source they cover, under lua/.
          find_files = function()
            return #_G.arg > 0 and _G.arg or vim.fn.globpath("lua", "**/*_spec.lua", true, true)
          end,
        },
      },
    },
  },
})
