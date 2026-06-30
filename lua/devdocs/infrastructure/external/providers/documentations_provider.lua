local make_logged = require("devdocs.application.helpers.make_logged")

---@type DocumentationsProviderPort
local M = {
  find = function(id)
    assert(type(id) == "string", "slug must be a string")

    local http_client = require("devdocs.infrastructure.external.clients.http_client")
    local url = string.format("https://documents.devdocs.io/%s/db.json", id)

    -- TODO: use environment variable
    local response = http_client.get(url)
    local body = vim.fn.json_decode(response.body)

    if body == nil then
      return nil
    end

    return body
  end,

  find_async = function(id, on_success)
    assert(type(id) == "string", "slug must be a string")
    assert(type(on_success) == "function", "on_success must be a function")

    local http_client = require("devdocs.infrastructure.external.clients.http_client")
    local url = string.format("https://documents.devdocs.io/%s/db.json", id)

    http_client.get_async(url, function(response)
      local body = vim.fn.json_decode(response.body)
      if body == nil or body == vim.NIL then
        on_success(nil)
        return
      end
      on_success(body)
    end)
  end,
}

return make_logged("external/providers/documentations", M)
