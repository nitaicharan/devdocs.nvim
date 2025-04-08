---@class IDocumentationsUseCase
---@field install fun(request: IDocumentationsRequest, repository: IDocumentationsRepository, name: string): table<string, string>[] | nil
---@field show fun(repository: IDocumentationsRepository, picker: IPicker, id: string)

---@type IDocumentationsUseCase
return {
  install = function(request, repository, id)
    assert(type(request) ~= "nil", "request param is required")
    assert(type(repository) ~= "nil", "repository param is required")
    assert(type(id) == "string", "id must be a string")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    log_usecase.debug("[documentations_usecase->install]:" .. vim.inspect({ id = id }))

    local documentation = request.list(id)
    if documentation == nil then
      return
    end

    repository.save(documentation, id)
    return documentation;
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
