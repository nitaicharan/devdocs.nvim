local make_logged = require("devdocs.application.helpers.make_logged")

---@type ILocksRepository
return make_logged("locks_repository", {
  save = function(lock)
    assert(type(lock) ~= "nil", "lock param is required")

    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, "documentations-lock.json")

    local data = file_util.read(path) or {}

    data[lock.id] = {
      id = lock.id,
      name = lock.name,
      installed_at = data.installed_at or vim.fn.strftime("%Y-%m-%dT%H:%M:%S%z"),
      updated_at = data.updated_at or vim.fn.strftime("%Y-%m-%dT%H:%M:%S%z")
    }

    file_util.write(path, data)
  end,
  list = function()
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, "documentations-lock.json")

    return file_util.read(path)
  end
})
