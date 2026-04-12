---@class IDocumentationsUseCase
---@field install fun(request: IDocumentationsRequest, repository: IDocumentationsRepository, registries_repository: IRegistriesRepository, entries_request: IEntriesRequest, entries_repository: IEntriesRepository, locks_repository:ILocksRepository, picker: IPicker, id?: string): table<string, string>[] | nil
---@field show fun(repository: IDocumentationsRepository, locks_repository:ILocksRepository, picker: IPicker, buffer: IBufferAdapter, id?: string)

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IDocumentationsUseCase
return make_logged("documentations_usecase", {
  install = function(request, repository, registries_repository, entries_request, entries_repository, locks_repository,
                     picker, id)
    id = id or ""

    assert(type(request) ~= "nil", "request param is required")
    assert(type(repository) ~= "nil", "repository param is required")
    assert(type(registries_repository) ~= "nil", "registries_repository param is required")
    assert(type(picker) ~= "nil", "picker param is required")
    assert(type(id) == "string", "id must be a string")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local registeries_usecase = require("devdocs.application.usecases.registries_usecase")
    local entries_usecase = require("devdocs.application.usecases.entries_usecase")

    local callback = function(registry)
      assert(type(registry) ~= "nil", "registry param is required")

      if registry == nil then
        return;
      end

      log_usecase.info(string.format("Installing %s documentation...", registry.name))

      request.find_async(registry.slug, function(documentation)
        if documentation == nil then
          log_usecase.error(string.format("Failed to fetch %s documentation", registry.name))
          return
        end

        repository.save(documentation, registry.slug)

        entries_usecase.install_async(entries_request, entries_repository, registry.slug, function()
          locks_repository.save({ id = registry.slug, name = registry.name })
          log_usecase.info(string.format("%s documentation installed successfully", registry.name))
        end)
      end)
    end

    local registries = registeries_usecase.list(registries_repository)
    if registries == nil then
      return log_usecase.error("Registries not found!")
    end

    if (id == "") then
      return picker.registries(callback, registries)
    end

    callback(id)
  end,

  show = function(repository, locks_repository, picker, buffer, id)
    id = id or ""

    assert(type(repository) ~= "nil", "repository param is required")
    assert(type(buffer) ~= "nil", "buffer param is required")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local entries_usecase = require("devdocs.application.usecases.entries_usecase")

    local locks_callback = function(lock)
      local entries = entries_usecase.find(lock.id)
      if entries == nil then
        return log_usecase.error(string.format("Entry  %s not found", lock.name))
      end

      -- TODO: remove nested callbacks
      local callback = function(entry)
        local document_path = vim.split(entry.path, "#")
        local path = document_path[1]

        local document = repository.find(lock.id, path)
        local lines = vim.split(document, "\n")

        buffer.create_scratch_buffer(lines, 'markdown')
      end

      picker.entries(callback, lock.id, entries)
    end

    local result = locks_repository.list() or {}
    if (id == "") then
      return picker.locks(locks_callback, vim.tbl_values(result))
    end
  end
})
