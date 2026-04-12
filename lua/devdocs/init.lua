return {
  setup = function()
    local registries_request = require("devdocs.infrastructure.requests.registries_request")
    local registries_repository = require("devdocs.infrastructure.repositories.registeries_repository")
    local lifecycle_usecase = require("devdocs.application.usecases.lifecycle_usecase")

    lifecycle_usecase.on_plugin_init(registries_request, registries_repository)
  end,
  ui = {
    documentations = require("devdocs.infrastructure.uis.documentations_ui"),
  },
  api = {
    documentations = require("devdocs.infrastructure.apis.documentations_api"),
  }
}
