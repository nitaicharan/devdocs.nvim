local M = {
  setup = function()
    require("devdocs.infrastructure")
    require("devdocs.application.usecases.lifecycle_usecase").on_plugin_init()
  end,

  ui = {
    documentations = require("devdocs.presentation.documentations_ui"),
  },

  api = {
    documentations = require("devdocs.presentation.documentations_api"),
  }
}

return M
