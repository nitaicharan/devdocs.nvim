local M = {}

M.setup = function()
  require("devdocs.infrastructure.adapters")
  require("devdocs.application.usecases.lifecycle_usecase").on_plugin_init()
end

M.ui = {
  documentations = require("devdocs.presentation.documentations_ui"),
}

M.api = {
  documentations = require("devdocs.presentation.documentations_api"),
}

return M
