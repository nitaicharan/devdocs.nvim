---@type ILocksRepository
return {
  save = function(lock)
    assert(type(lock) ~= "nil", "lock param is required")

    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")
    local log_usecase = require("devdocs.application.usecases.log_usecase")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, "documentations-lock.json")

    local data = file_util.read(path) or {}

    data[lock.id] = {
      id = lock.id,
      name = lock.name,
      installed_at = data.installed_at or vim.fn.strftime("%Y-%m-%dT%H:%M:%S%z"),
      updated_at = data.updated_at or vim.fn.strftime("%Y-%m-%dT%H:%M:%S%z")
    }

    log_usecase.debug("[locks_repository->save]:" .. vim.inspect({ path = path }))

    file_util.write(path, data)
  end,
  list = function()
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, "documentations-lock.json")
    log_usecase.debug("[locks_repository->list]:" .. vim.inspect({ path = path }))

    return file_util.read(path)
  end
}
