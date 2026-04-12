---@class IHttpClient
---@field get fun(url: string, options?: table): any

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IHttpClient
return make_logged("http_client", {
  get = function(url, options)
    assert(type(url) == "string", "url must be a string")

    local curl = require("plenary.curl")

    return curl.get(url, options)
  end
})
