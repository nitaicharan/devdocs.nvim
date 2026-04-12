---@class IRegistriesRepository
---@field save fun(registry: RegistryModel[])
---@field list fun(): RegistryModel | nil

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IRegistriesRepository
return make_logged("registeries_repository", {
  save = function(data)
    assert(type(data) ~= "nil", "data param is required")

    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, "registry.json")

    file_util.write(path, data)
  end,

  list = function()
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, "registry.json")

    return file_util.read(path)
  end
})
