---@class IDocumentationsRequest
---@field find fun(slug: string): table<string,string>[] | nil
---@field find_async fun(slug: string, on_success: fun(result: table<string,string>[] | nil))

local make_logged_helper = require("devdocs.application.helpers.make_logged")
local make_logged = make_logged_helper.make_logged

---@type IDocumentationsRequest
return make_logged("documentations_request", {
  find = function(id)
    assert(type(id) == "string", "slug must be a string")

    local http_client = require("devdocs.infrastructure.clients.http_client")
    local url = string.format("https://documents.devdocs.io/%s/db.json", id)
    local devdocs_adapter = require("devdocs.infrastructure.adapters.devdocs_adapter")

    -- TODO: use environment variable
    local response = http_client.get(url)
    local body = vim.fn.json_decode(response.body)

    if body == nil then
      return nil
    end

    return devdocs_adapter.transform_documentations(body)
  end,

  find_async = function(id, on_success)
    assert(type(id) == "string", "slug must be a string")
    assert(type(on_success) == "function", "on_success must be a function")

    local http_client = require("devdocs.infrastructure.clients.http_client")
    local url = string.format("https://documents.devdocs.io/%s/db.json", id)
    local devdocs_adapter = require("devdocs.infrastructure.adapters.devdocs_adapter")

    http_client.get_async(url, function(response)
      local body = vim.fn.json_decode(response.body)
      if body == nil or body == vim.NIL then
        on_success(nil)
        return
      end
      on_success(devdocs_adapter.transform_documentations(body))
    end)
  end,
})
