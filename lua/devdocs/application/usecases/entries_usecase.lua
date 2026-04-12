---@class IEntriesUseCase
---@field install fun(request: IEntriesRequest, repository: IEntriesRepository, slug: string)
---@field find fun(slug: string): EntryModel[] | nil

local make_logged = require("devdocs.application.helpers.make_logged")

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

  find = function(id)
    assert(type(id) == "string", "id must be a string")

    local repository = require("devdocs.infrastructure.repositories.entries_repository")

    return repository.find(id)
  end
})
