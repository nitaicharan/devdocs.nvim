---@class IEntriesRequest
---@field list fun(slug: string): EntryModel[] | nil

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IEntriesRequest
return make_logged("entries_request", {
  list = function(slug)
    assert(type(slug) == "string", "slug must be a string")

    local http_client = require("devdocs.infrastructure.clients.http_client")
    local devdocs_adapter = require("devdocs.infrastructure.adapters.devdocs_adapter")

    -- TODO: use environment variable
    local url = string.format("https://documents.devdocs.io/%s/index.json", slug)

    local response = http_client.get(url)
    local result = vim.fn.json_decode(response.body)

    if result == nil then
      return nil
    end

    return devdocs_adapter.transform_entries(result, slug)
  end
})
