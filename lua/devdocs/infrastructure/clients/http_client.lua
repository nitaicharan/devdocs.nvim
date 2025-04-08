---@class IHttpClient
---@field get fun(url: string, options?: table): any

---@type IHttpClient
return {
  get = function(url, options)
    assert(type(url) == "string", "url must be a string")

    local log_usecase = require("devdocs.application.usecases.log_usecase")

    log_usecase.debug("[http_client->get]:" .. vim.inspect({ url = url }))

    local curl = require("plenary.curl")

    return curl.get(url, options)
  end
}
