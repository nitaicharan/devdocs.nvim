---@class IDocumentationsUseCase
---@field install fun(request: IDocumentationsRequest, repository: IDocumentationsRepository, registries_repository: IRegistriesRepository, entries_request: IEntriesRequest, entries_repository: IEntriesRepository, picker: IPicker, id: string): table<string, string>[] | nil
---@field show fun(repository: IDocumentationsRepository, picker: IPicker, id: string)

---@type IDocumentationsUseCase
return {
  install = function(request, repository, registries_repository, entries_request, entries_repository, picker, id)
    id = id or ""

    assert(type(request) ~= "nil", "request param is required")
    assert(type(repository) ~= "nil", "repository param is required")
    assert(type(registries_repository) ~= "nil", "registries_repository param is required")
    assert(type(picker) ~= "nil", "picker param is required")
    assert(type(id) == "string", "id must be a string")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local registeries_usecase = require("devdocs.application.usecases.registries_usecase")
    local entries_usecase = require("devdocs.application.usecases.entries_usecase")
    log_usecase.debug("[documentations_usecase->install]:" .. vim.inspect({ id = id }))


    local callback = function(slug)
      assert(type(slug) == "string", "slug must be a string")
      -- assert(type(slug) == "string" and slug ~= "", "slug must be a non-empty string")


      if slug == "" then
        return;
      end

      log_usecase.debug("[documentations_usecase->callback]:" .. vim.inspect({ slug = slug }))

      -- TODO check if it already installed before feching it
      -- TODO make documentation installation in parallel
      -- TODO notify user in case of a large documentation
      -- TODO log in `warn` level in case of large documeantation
      local documentation = request.list(slug)
      if documentation == nil then
        return
      end

      repository.save(documentation, slug)
      -- TODO: move it to a event listern about document creation
      entries_usecase.install(entries_request, entries_repository, slug)
    end

    local regiestries = registeries_usecase.find(registries_repository)

    if (id == "") then
      id = picker.registries(callback, regiestries)
    end
  end,

  show = function(repository, picker, id)
    assert(type(id) == "string", "id must be a string")
    assert(type(repository) ~= "nil", "repository param is required")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local entries_usecase = require("devdocs.application.usecases.entries_usecase")

    log_usecase.debug("[documentations_usecase->install]:" .. vim.inspect({ id = id }))


    local entries = vim.fn.json_decode(entries_usecase.find(id))

    if entries == nil then
      return
    end


    local callback = function(item)
      if item == nil then
        return
      end

      local document_path = vim.split(item, "#")
      local path = document_path[1]

      local document = repository.find(id, path)
      local lines = vim.split(document, "\n")

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buf })
      vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
      vim.api.nvim_set_current_buf(buf)
    end

    picker.entries(callback, id, entries)
  end
}
