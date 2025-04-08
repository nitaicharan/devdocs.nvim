---@class ILogUseCase
---@field debug fun(message: string)
---@field info fun(message: string)
---@field warn fun(message: string)
---@field error fun(message: string)

local notify = vim.schedule_wrap(
  function(message, level)
    vim.notify(message, level)
  end
)

---@type ILogUseCase
return {
  debug = function(message)
    local setup_config = require("devdocs.domain.defaults.setup_config")
    if not setup_config.debug_mode then
      return
    end

    notify(message, vim.log.levels.DEBUG)
  end,

  info = function(message)
    notify(message, vim.log.levels.INFO)
  end,

  warn = function(message)
    notify(message, vim.log.levels.WARN)
  end,

  error = function(message)
    notify(message, vim.log.levels.ERROR)
  end
}
