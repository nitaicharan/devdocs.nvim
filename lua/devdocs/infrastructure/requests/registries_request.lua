---@class IRegistriesRequest
---@field list fun(): RegistryModel[]

---@type IRegistriesRequest
return {
  list = function()
    local http_client = require("devdocs.infrastructure.clients.http_client")
    local log_usecase = require("devdocs.application.usecases.log_usecase")

    -- TODO: use environment variable
    local url = "https://devdocs.io/docs.json"
    local response = http_client.get(url, {
      headers = {
        ["User-agent"] = "chrome", -- fake user agent, see #25
      },
    })

    log_usecase.debug("[registries_request->retrive]:" .. vim.inspect({ url = url }))

    return vim.fn.json_decode(response.body)
  end
}
