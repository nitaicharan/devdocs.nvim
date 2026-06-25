local make_logged = require("devdocs.application.helpers.make_logged")

local M = {}

---@param registery_name string
---@param callback? fun(slug: string)
---@return string[]
M.list = function(registery_name, callback)
  assert(type(callback) == "function", "callback must be a function")
  if callback then
    assert(type(registery_name) == "string", "registery_name must be a string")
  end

  local registries_usecase = require("devdocs.application.usecases.registries_usecase")
  local registry = registries_usecase.list()

  return vim.tbl_map(function(document)
    return document.slug
  end, registry)
end

---@param slug string
M.install = function(slug)
  assert(type(slug) == "string", "slug must be a string")

  local usecase = require("devdocs.application.usecases.documentations_usecase")
  usecase.install(slug)
end

return make_logged("apis/documentations", M)
