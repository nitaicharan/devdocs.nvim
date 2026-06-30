local make_logged = require("devdocs.application.helpers.make_logged")

---@class EntriesUsecase
local M = {
  ---@param id string
  install = function(id)
    assert(type(id) == "string", "id must be a string")

    local container = require("devdocs.application.ports.dependency_registry")
    local provider = container.entries_provider()
    local repository = container.entries_repository()

    local entries = provider.list(id)
    if entries == nil then
      return
    end

    repository.save(entries, id)
  end,

  ---@param id string
  ---@param on_done? fun()
  install_async = function(id, on_done)
    assert(type(id) == "string", "id must be a string")

    local container = require("devdocs.application.ports.dependency_registry")
    local provider = container.entries_provider()
    local repository = container.entries_repository()

    provider.list_async(id, function(entries)
      if entries == nil then
        if on_done then on_done() end
        return
      end
      repository.save(entries, id)
      if on_done then on_done() end
    end)
  end,

  ---@param id string
  ---@return EntryModel[] | nil
  find = function(id)
    assert(type(id) == "string", "id must be a string")

    local container = require("devdocs.application.ports.dependency_registry")
    local repository = container.entries_repository()

    return repository.find(id)
  end
}

return make_logged("usecases/entries", M)
