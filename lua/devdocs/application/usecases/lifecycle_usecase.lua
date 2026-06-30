local make_logged = require("devdocs.application.helpers.make_logged")

---@class LifecycleUsecase
local M = {}

M.on_plugin_init = function()
  require("devdocs.application.usecases.registries_usecase").install()
end

return make_logged("usecases/lifecycle", M)
