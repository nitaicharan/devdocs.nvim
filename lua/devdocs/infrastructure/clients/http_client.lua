---@class IHttpClient
---@field get fun(url: string, options?: table): any
---@field get_async fun(url: string, callback: fun(response: any), options?: table)

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IHttpClient
return make_logged("http_client", {
  get = function(url, options)
    assert(type(url) == "string", "url must be a string")

    local curl = require("plenary.curl")

    return curl.get(url, options)
  end,

  get_async = function(url, callback, options)
    assert(type(url) == "string", "url must be a string")
    assert(type(callback) == "function", "callback must be a function")

    local curl = require("plenary.curl")
    options = options or {}
    options.callback = callback

    curl.get(url, options)
  end,
})
