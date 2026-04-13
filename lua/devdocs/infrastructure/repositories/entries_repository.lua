---@class IEntriesRepository
---@field save fun(entries: EntryModel[], name: string)
---@field find fun(name: string): EntryModel[] | nil

local make_logged_helper = require("devdocs.application.helpers.make_logged")
local make_logged = make_logged_helper.make_logged

---@type IEntriesRepository
return make_logged("entries_repository", {
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
})
