---@class IDocumentationsRepository
---@field save fun(documentations: table<string,string>, slug: string)
---@field find fun(is: string, slug: string): string

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IDocumentationsRepository
return make_logged("documentations_repository", {
  save = function(documentation, id)
    assert(type(documentation) == "table", "documentations param is required")
    assert(type(id) == "string", "id must be a string")

    local pandas_client = require("devdocs.infrastructure.clients.pandas_client")
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local counter = 0
    for slug, document in pairs(documentation) do
      local success, markdown = xpcall(pandas_client.html_to_markdown, debug.traceback, document)

      if not success then
        return
      end

      local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, id, slug .. '.md')

      file_util.write(path, markdown)
      counter = counter + 1
    end
  end,

  find = function(id, slug)
    assert(type(id) == "string", "id must be a string")
    assert(type(slug) == "string", "id must be a string")

    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, id, slug .. '.md')
    return file_util.read(path)
  end,
})
