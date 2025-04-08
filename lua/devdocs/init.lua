local request = require("devdocs.infrastructure.requests.registries_request")
local repository = require("devdocs.infrastructure.repositories.registeries_repository")
local usecase = require("devdocs.application.usecases.lifecycle_usecase")
local ui = require("devdocs.infrastructure.uis.documentations_ui")

-- usecase.on_plugin_init(request, repository)
-- ui.install("markdown")
ui.show("markdown")

return {
  setup = function()
    local registries_request = require("devdocs.infrastructure.requests.registries_request")
    local registries_repository = require("devdocs.infrastructure.repositories.registeries_repository")
    local documentations_ui = require("devdocs.infrastructure.uis.documentations_ui")
    local lifecycle_usecase = require("devdocs.application.usecases.lifecycle_usecase")

    lifecycle_usecase.on_plugin_init(registries_request, registries_repository)

    return {
      documentations = documentations_ui,
      api = {
        documentations = require("devdocs.infrastructure.apis.documentations_api"),
      }
    }
  end
}
