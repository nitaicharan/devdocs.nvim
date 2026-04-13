---@class IEntriesUseCase
---@field install fun(request: IEntriesRequest, repository: IEntriesRepository, slug: string)
---@field install_async fun(request: IEntriesRequest, repository: IEntriesRepository, slug: string, on_done?: fun())
---@field find fun(slug: string): EntryModel[] | nil

local make_logged_helper = require("devdocs.application.helpers.make_logged")
local make_logged = make_logged_helper.make_logged

---@type IEntriesUseCase
return make_logged("entries_usecase", {
  install = function(request, repository, id)
    assert(type(request) ~= "nil", "request param is required")
    assert(type(repository) ~= "nil", "repository param is required")
    assert(type(id) == "string", "id must be a string")

    local entries = request.list(id)
    if entries == nil then
      return
    end

    repository.save(entries, id)
  end,

  install_async = function(request, repository, id, on_done)
    assert(type(request) ~= "nil", "request param is required")
    assert(type(repository) ~= "nil", "repository param is required")
    assert(type(id) == "string", "id must be a string")

    request.list_async(id, function(entries)
      if entries == nil then
        if on_done then on_done() end
        return
      end
      repository.save(entries, id)
      if on_done then on_done() end
    end)
  end,

  find = function(id)
    assert(type(id) == "string", "id must be a string")

    local repository = require("devdocs.infrastructure.repositories.entries_repository")

    return repository.find(id)
  end
})
