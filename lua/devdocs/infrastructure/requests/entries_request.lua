---@class IEntriesRequest
---@field list fun(slug: string): EntryModel[] | nil

---@type IEntriesRequest
return {
  list = function(slug)
    assert(type(slug) == "string", "slug must be a string")

    local http_client = require("devdocs.infrastructure.clients.http_client")
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local devdocs_adapter = require("devdocs.infrastructure.adapters.devdocs_adapter")

    -- TODO: use environment variable
    local url = string.format("https://documents.devdocs.io/%s/index.json", slug)
    log_usecase.debug("[entries_request->list]:" .. vim.inspect({ url = url }))

    local response = http_client.get(url)
    local result = vim.fn.json_decode(response.body)

    if result == nil then
      return nil
    end

    return devdocs_adapter.transform_entries(result, slug)
  end
}
