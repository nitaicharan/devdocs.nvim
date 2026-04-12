---@class IEntriesRequest
---@field list fun(slug: string): EntryModel[] | nil
---@field list_async fun(slug: string, on_success: fun(result: EntryModel[] | nil))

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
  end,

  list_async = function(slug, on_success)
    assert(type(slug) == "string", "slug must be a string")
    assert(type(on_success) == "function", "on_success must be a function")

    local http_client = require("devdocs.infrastructure.clients.http_client")
    local devdocs_adapter = require("devdocs.infrastructure.adapters.devdocs_adapter")
    local url = string.format("https://documents.devdocs.io/%s/index.json", slug)

    http_client.get_async(url, function(response)
      local result = vim.fn.json_decode(response.body)
      if result == nil or result == vim.NIL then
        on_success(nil)
        return
      end
      on_success(devdocs_adapter.transform_entries(result, slug))
    end)
  end,
})
