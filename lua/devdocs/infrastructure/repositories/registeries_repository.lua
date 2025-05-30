---@class IRegistriesRepository
---@field save fun(registry: RegistryModel[])
---@field list fun(): RegistryModel | nil

---@type IRegistriesRepository
return {
  save = function(data)
    assert(type(data) ~= "nil", "data param is required")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, "registry.json")

    log_usecase.debug("[registries_repository->save]:" .. vim.inspect({ path = path }))

    file_util.write(path, data)
  end,

  list = function()
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, "registry.json")

    log_usecase.debug("[registries_repository->find]:" .. vim.inspect({ path = path }))

    return file_util.read(path)
  end
}
