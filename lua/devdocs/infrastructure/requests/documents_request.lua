---@class IDocumentsRequest
---@field get fun(slug: string,document_path: string): string

---@type IDocumentsRequest
return {
  get = function(slug, document_path)
    assert(type(slug) == "string", "slug must be a string")
    assert(type(document_path) == "string", "document_path must be a string")

    local http_client = require("devdocs.infrastructure.clients.http_client")
    local log_usecase = require("devdocs.application.usecases.log_usecase")

    local url = string.format("https://devdocs.io/%s/%s", slug, document_path)
    log_usecase.debug("[documentations_request->list]:" ..
      vim.inspect({ slug = slug, document_path = document_path, url = url }))

    -- TODO: use environment variable
    local response = http_client.get(url)
    return response.body
  end
}
