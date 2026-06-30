local notifier = require("devdocs.infrastructure.editor.notifier")

return {
  ---@param message string
  debug = function(message)
    local setup_config = require("devdocs.domain.defaults.setup_config")
    if not setup_config.debug_mode then
      return
    end

    notifier.notify(message, notifier.levels.DEBUG)
  end,

  ---@param message string
  info = function(message)
    notifier.notify(message, notifier.levels.INFO)
  end,

  ---@param message string
  warn = function(message)
    notifier.notify(message, notifier.levels.WARN)
  end,

  ---@param message string
  error = function(message)
    notifier.notify(message, notifier.levels.ERROR)
  end,
}
