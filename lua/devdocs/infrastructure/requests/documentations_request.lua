---@class IDocumentationsRequest
---@field list fun(slug: string): table<string,string>[] | nil

---@type IDocumentationsRequest
return {
  list = function(id)
    assert(type(id) == "string", "slug must be a string")

    local http_client = require("devdocs.infrastructure.clients.http_client")
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local url = string.format("https://documents.devdocs.io/%s/db.json", id)
    local devdocs_adapter = require("devdocs.infrastructure.adapters.devdocs_adapter")

    log_usecase.debug("[documentations_request->list]:" .. vim.inspect({ slug = id, url = url }))

    -- TODO: use environment variable
    local response = http_client.get(url)
    local body = vim.fn.json_decode(response.body)

    if body == nil then
      return nil
    end

    return devdocs_adapter.transform_documentations(body)
  end
}
