---@class INotifierAdapter
---@field notify fun(message: string, level: number)
---@field levels table

local notify = vim.schedule_wrap(function(message, level)
  vim.notify(message, level)
end)

---@type INotifierAdapter
return {
  notify = notify,
  levels = vim.log.levels,
}
