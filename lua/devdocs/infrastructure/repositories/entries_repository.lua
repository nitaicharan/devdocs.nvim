---@class IEntriesRepository
---@field save fun(entries: EntryModel[], name: string)
---@field find fun(name: string): EntryModel[] | nil

---@type IEntriesRepository
return {
  save = function(data, id)
    assert(type(data) ~= "nil", "data param is required")
    assert(type(id) == "string", "name must be a string")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, id, "/index.json")

    log_usecase.debug("[entries_repository->save]:" .. vim.inspect({ path = path }))

    -- TODO: check be best way to change between adapters (factory or singleton partner)
    file_util.write(path, data)
  end,

  find = function(id)
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, id, "index.json")
    log_usecase.debug("[entries_repository->find]:" .. vim.inspect({ path = path }))

    return file_util.read(path)
  end
}
