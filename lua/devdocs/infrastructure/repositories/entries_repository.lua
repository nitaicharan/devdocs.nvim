local make_logged = require("devdocs.application.helpers.make_logged")

---@type EntriesPersistencePort
local M = {
  save = function(data, id)
    assert(type(data) ~= "nil", "data param is required")
    assert(type(id) == "string", "name must be a string")

    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, id, "/index.json")

    -- TODO: check be best way to change between adapters (factory or singleton partner)
    file_util.write(path, data)
  end,

  find = function(id)
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, id, "index.json")

    return file_util.read(path)
  end
}

return make_logged("repositories/entries", M)
