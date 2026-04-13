---@class IRegistriesRequest
---@field list fun(): RegistryModel[]

local make_logged_helper = require("devdocs.application.helpers.make_logged")
local make_logged = make_logged_helper.make_logged

---@type IRegistriesRequest
return make_logged("registries_request", {
  list = function()
    local http_client = require("devdocs.infrastructure.clients.http_client")

    -- TODO: use environment variable
    local url = "https://devdocs.io/docs.json"
    local response = http_client.get(url, {
      headers = {
        ["User-agent"] = "chrome", -- fake user agent, see #25
      },
    })

    return vim.fn.json_decode(response.body)
  end
})
