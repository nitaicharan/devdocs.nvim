local make_logged = require("devdocs.application.helpers.make_logged")

local M = {}

---@param url string
---@param options? table
---@return any
M.get = function(url, options)
  assert(type(url) == "string", "url must be a string")

  local curl = require("plenary.curl")

  return curl.get(url, options)
end

---@param url string
---@param callback fun(response: any)
---@param options? table
M.get_async = function(url, callback, options)
  assert(type(url) == "string", "url must be a string")
  assert(type(callback) == "function", "callback must be a function")

  local curl = require("plenary.curl")
  options = options or {}
  options.callback = vim.schedule_wrap(callback)

  curl.get(url, options)
end

return make_logged("external/clients/http_client", M)
