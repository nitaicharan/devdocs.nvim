---@class IDocumentsRepository
---@field save fun(documentation_slug: string, slug: string, content: string)

---@type IDocumentsRepository
return {
  save = function(documentation_slug, id, content)
    assert(type(documentation_slug) == "string", "documentation_slug must be a string")
    assert(type(id) == "string", "id must be a string")
    assert(type(content) == "string", "content must be a string")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local pandas_client = require("devdocs.infrastructure.clients.pandas_client")
    local file_util = require("devdocs.infrastructure.utils.files_util")
    local setup_config = require("devdocs.domain.defaults.setup_config")

    log_usecase.debug("[documents_repository->save]:" ..
      vim.inspect({ documentation_slug = documentation_slug, id = id, content = content }))

    local success, markdown = xpcall(pandas_client.html_to_markdown, debug.traceback, content)
    if not success then
      return
    end

    local path = file_util.joinpath(vim.fn.stdpath("data"), "devdocs", setup_config.plataform, documentation_slug,
      id .. '.md')

    file_util.write(path, markdown)
  end
}
