---@param message string
---@param level number
local notify = vim.schedule_wrap(function(message, level)
  vim.notify(message, level)
end)

return {
  notify = notify,
  levels = vim.log.levels,
}
