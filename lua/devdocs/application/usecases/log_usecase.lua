---@class ILogUseCase
---@field debug fun(message: string)
---@field info fun(message: string)
---@field warn fun(message: string)
---@field error fun(message: string)

local notifier = require("devdocs.infrastructure.adapters.notifier")

---@type ILogUseCase
return {
  debug = function(message)
    local setup_config = require("devdocs.domain.defaults.setup_config")
    if not setup_config.debug_mode then
      return
    end

    notifier.notify(message, notifier.levels.DEBUG)
  end,

  info = function(message)
    notifier.notify(message, notifier.levels.INFO)
  end,

  warn = function(message)
    notifier.notify(message, notifier.levels.WARN)
  end,

  error = function(message)
    notifier.notify(message, notifier.levels.ERROR)
  end
}
