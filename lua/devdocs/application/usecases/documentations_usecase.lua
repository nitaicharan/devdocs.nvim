local make_logged = require("devdocs.application.helpers.make_logged")

---@class DocumentationsUsecase
local M = {
  ---@param id? string
  install = function(id)
    id = id or ""
    assert(type(id) == "string", "id must be a string")

    local container = require("devdocs.application.ports.dependency_registry")
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local registeries_usecase = require("devdocs.application.usecases.registries_usecase")
    local entries_usecase = require("devdocs.application.usecases.entries_usecase")

    local provider = container.documentations_provider()
    local repository = container.documentations_repository()
    local locks_repository = container.locks_repository()
    local picker = container.picker()

    local callback = function(registry)
      assert(type(registry) ~= "nil", "registry param is required")

      if registry == nil then
        return;
      end

      log_usecase.info(string.format("Installing %s documentation...", registry.name))

      provider.find_async(registry.slug, function(documentation)
        if documentation == nil then
          log_usecase.error(string.format("Failed to fetch %s documentation", registry.name))
          return
        end

        repository.save_async(documentation, registry.slug, function()
          entries_usecase.install_async(registry.slug, function()
            locks_repository.save({ id = registry.slug, name = registry.name })
            log_usecase.info(string.format("%s documentation installed successfully", registry.name))
          end)
        end)
      end)
    end

    local registries = registeries_usecase.list()
    if registries == nil then
      return log_usecase.error("Registries not found!")
    end

    if (id == "") then
      return picker.registries(callback, registries)
    end

    callback(id)
  end,

  ---@param id? string
  show = function(id)
    id = id or ""

    local container = require("devdocs.application.ports.dependency_registry")
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local entries_usecase = require("devdocs.application.usecases.entries_usecase")

    local repository = container.documentations_repository()
    local locks_repository = container.locks_repository()
    local picker = container.picker()
    local buffer = container.buffer()

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
}

return make_logged("usecases/documentations", M)
