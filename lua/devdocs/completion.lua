local M = {}

local list = require("devdocs.list")

---@param args string[]
---@param arg_lead string
local function filter_args(args, arg_lead)
  local filtered = vim.tbl_filter(function(entry)
    return vim.startswith(entry, arg_lead)
  end, args)
  return filtered
end

M.get_installed = function(arg_lead)
  local installed = list.get_installed_alias()
  return filter_args(installed, arg_lead)
end

M.get_non_installed = function(arg_lead)
  local non_installed = list.get_non_installed_alias()
  return filter_args(non_installed, arg_lead)
end

M.get_updatable = function(arg_lead)
  local updatable = list.get_updatable()
  return filter_args(updatable, arg_lead)
end

return M
