local M = {}

M.setup = function()
  require("devdocs.infrastructure.adapters")

  local lifecycle_usecase = require("devdocs.application.usecases.lifecycle_usecase")
  lifecycle_usecase.on_plugin_init()
end

M.ui = {
  documentations = require("devdocs.infrastructure.uis.documentations_ui"),
}

M.api = {
  documentations = require("devdocs.infrastructure.apis.documentations_api"),
}

return M
