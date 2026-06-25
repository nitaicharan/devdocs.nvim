local make_logged = require("devdocs.application.helpers.make_logged")

local M = {}

M.install = function()
  local ports = require("devdocs.application.ports.adapter_registry")
  local request = ports.registries_request()
  local repository = ports.registries_repository()

  local registery = repository.list()
  if registery ~= nil then
    return
  end

  local data = request.list()
  repository.save(data)
end

---@return RegistryModel[] | nil
M.list = function()
  local ports = require("devdocs.application.ports.adapter_registry")
  local repository = ports.registries_repository()

  return repository.list()
end

return make_logged("usecases/registries", M)
