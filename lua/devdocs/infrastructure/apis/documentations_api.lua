---@class IDocumentatiosApi
---@field list fun(registery_name: string, callback?: fun(slug: string)): string[]
---@field install fun(registery_name: string, slug: string)

---@type IDocumentatiosApi
local api = {
  list = function(registery_name, callback)
    assert(type(callback) == "function", "callback must be a function")
    if callback then
      assert(type(registery_name) == "string", "registery_name must be a string")
    end

    local registries_usecase = require("devdocs.application.usecases.registries_usecase")
    local registries_repository = require("devdocs.infrastructure.repositories.registeries_repository")

    local registry = registries_usecase.list(registries_repository, registery_name)

    return vim.tbl_map(function(document)
      return document.slug
    end, registry)
  end,

  install = function(slug)
    assert(type(slug) == "string", "slug must be a string")

    local usecase = require("devdocs.application.usecases.documentations_usecase")
    local request = require("devdocs.infrastructure.requests.documentations_request")
    local repository = require("devdocs.infrastructure.repositories.documentations_repository")
    local registries_repository = require("devdocs.infrastructure.repositories.registeries_repository")
    local snack_picker = require("devdocs.infrastructure.pickers.snacks_picker")

    usecase.install(request, repository, registries_repository, snack_picker, slug)
  end,
}

return api
