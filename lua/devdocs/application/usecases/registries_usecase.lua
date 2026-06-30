local make_logged = require("devdocs.application.helpers.make_logged")
local container = require("devdocs.application.ports.dependency_registry")

---@class RegistriesUsecase
local M = {
  install = function()
    local provider = container.registries_provider()
    local repository = container.registries_repository()

    local registery = repository.list()
    if registery ~= nil then
      return
    end

    local data = provider.list()
    repository.save(data)
  end,

  ---@return RegistryModel[] | nil
  list = function()
    local repository = container.registries_repository()

    return repository.list()
  end
}

return make_logged("usecases/registries", M)
