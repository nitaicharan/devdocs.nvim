local make_logged = require("devdocs.application.helpers.make_logged")

local M = {}

M.on_plugin_init = function()
  local registries_usecase = require("devdocs.application.usecases.registries_usecase")
  registries_usecase.install()
end

return make_logged("usecases/lifecycle", M)
