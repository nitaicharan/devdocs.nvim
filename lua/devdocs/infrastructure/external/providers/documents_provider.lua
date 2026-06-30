local make_logged = require("devdocs.application.helpers.make_logged")

---@type DocumentsProviderPort
local M = {
  get = function(slug, document_path)
    assert(type(slug) == "string", "slug must be a string")
    assert(type(document_path) == "string", "document_path must be a string")

    local http_client = require("devdocs.infrastructure.external.clients.http_client")

    local url = string.format("https://devdocs.io/%s/%s", slug, document_path)

    -- TODO: use environment variable
    local response = http_client.get(url)
    return response.body
  end
}

return make_logged("external/providers/documents", M)
