---@class IRegistriesUseCase
---@field install fun(request: IRegistriesRequest, repository: IRegistriesRepository)
---@field list fun(repository: IRegistriesRepository): RegistryModel[] | nil

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IRegistriesUseCase
return make_logged("registries_usecase", {
  install = function(request, repository)
    assert(type(request) ~= "nil", "request param is required")
    assert(type(repository) ~= "nil", "repository param is required")

    local registery = repository.list()
    if registery ~= nil then
      return
    end

    local data = request.list()
    repository.save(data)
  end,

  list = function(repository)
    assert(type(repository) ~= "nil", "repository param is required")

    return repository.list()
  end
})
