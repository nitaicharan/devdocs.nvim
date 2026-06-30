local make_logged = require("devdocs.application.helpers.make_logged")

---@type RegistriesProviderPort
local M = {
  list = function()
    local http_client = require("devdocs.infrastructure.external.clients.http_client")

    -- TODO: use environment variable
    local url = "https://devdocs.io/docs.json"
    local response = http_client.get(url, {
      headers = {
        ["User-agent"] = "chrome", -- fake user agent, see #25
      },
    })

    return vim.fn.json_decode(response.body)
  end
}

return make_logged("external/providers/registries", M)
