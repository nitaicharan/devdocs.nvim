---@class IEntriesUseCase
---@field install fun(request: IEntriesRequest, repository: IEntriesRepository, documentation: table<string, string> | nil, slug: string)
---@field find fun(slug: string): EntryModel[] | nil

---@type IEntriesUseCase
return {
  install = function(request, repository, documentation, id)
    assert(type(request) ~= "nil", "request param is required")
    assert(type(repository) ~= "nil", "repository param is required")
    assert(type(documentation) ~= "nil", "documentation param is required")
    assert(type(id) == "string", "id must be a string")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    log_usecase.debug("[entries_usecase->install]:" .. vim.inspect({ slug = id }))

    local entries = request.list(id)
    if entries == nil then
      return
    end

    -- local result = vim.tbl_map(function(entry)
    --   for key, value in pairs(documentation) do
    --   end
    --
    --   local documentation_paths = vim.tbl_keys(documentation)
    --   print(vim.inspect({ documentation_paths = documentation_paths, path = entry.path }))
    --
    --   -- local result = vim.tbl_extend("force", entry, { content = content })
    --   return entry
    -- end, entries)

    -- repository.save(result, id)
  end,

  find = function(id)
    assert(type(id) == "string", "id must be a string")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local repository = require("devdocs.infrastructure.repositories.entries_repository")

    log_usecase.debug("[entries_usecase->find]:" .. vim.inspect({ id = id }))


    return repository.find(id)
  end
}
