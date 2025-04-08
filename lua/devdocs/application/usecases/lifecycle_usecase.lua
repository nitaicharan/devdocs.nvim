return {
  ---@param registries_request IRegistriesRequest
  ---@param registries_repository IRegistriesRepository
  on_plugin_init = function(registries_request, registries_repository)
    assert(type(registries_request) ~= "nil", "registries_request param is required")
    assert(type(registries_repository) ~= "nil", "registries_repository param is required")

    local registries_usecase = require("devdocs.application.usecases.registries_usecase")

    registries_usecase.install(registries_request, registries_repository)
  end
}
