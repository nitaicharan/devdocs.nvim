---@class IDocumentsRequest
---@field get fun(slug: string,document_path: string): string

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IDocumentsRequest
return make_logged("documents_request", {
  get = function(slug, document_path)
    assert(type(slug) == "string", "slug must be a string")
    assert(type(document_path) == "string", "document_path must be a string")

    local http_client = require("devdocs.infrastructure.clients.http_client")

    local url = string.format("https://devdocs.io/%s/%s", slug, document_path)

    -- TODO: use environment variable
    local response = http_client.get(url)
    return response.body
  end
})
