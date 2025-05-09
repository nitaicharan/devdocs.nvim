---@class IRegistriesUseCase
---@field install fun(request: IRegistriesRequest, repository: IRegistriesRepository)
---@field find fun(repository: IRegistriesRepository): RegistryModel | nil

---@type IRegistriesUseCase
return {
  install = function(request, repository)
    assert(type(request) ~= "nil", "request param is required")
    assert(type(repository) ~= "nil", "repository param is required")

    local log_usecase = require("devdocs.application.usecases.log_usecase")

    log_usecase.debug("[registries_usecase->install]")

    local registery = repository.find()
    if registery ~= nil then
      return log_usecase.debug("[registries_usecase->install]: registery already installed")
    end

    local data = request.list()
    repository.save(data)
  end,

  find = function(repository)
    assert(type(repository) ~= "nil", "repository param is required")

    local log_usecase = require("devdocs.application.usecases.log_usecase")

    log_usecase.debug("[registries_usecase->find]")

    return repository.find()
  end
}
