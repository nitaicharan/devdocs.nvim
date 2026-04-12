---@class IDocumentatiosUi
---@field install fun(slug: string?)
---@field show fun(slug: string?)

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IDocumentatiosUi
return make_logged("documentations_ui", {
  install = function(id)
    local usecase = require("devdocs.application.usecases.documentations_usecase")
    local request = require("devdocs.infrastructure.requests.documentations_request")
    local repository = require("devdocs.infrastructure.repositories.documentations_repository")
    local entries_request = require("devdocs.infrastructure.requests.entries_request")
    local entries_repository = require("devdocs.infrastructure.repositories.entries_repository")
    local snacks_picker = require("devdocs.infrastructure.pickers.snacks_picker")
    local registeries_repository = require("devdocs.infrastructure.repositories.registeries_repository")
    local locks_repository = require("devdocs.infrastructure.repositories.locks_repository")

    local documentation = usecase.install(
      request,
      repository,
      registeries_repository,
      entries_request,
      entries_repository,
      locks_repository,
      snacks_picker,
      id
    )

    if documentation == nil then
      return
    end
  end,

  show = function(id)
    local usecase = require("devdocs.application.usecases.documentations_usecase")
    local repository = require("devdocs.infrastructure.repositories.documentations_repository")
    local snacks_picker = require("devdocs.infrastructure.pickers.snacks_picker")
    local locks_repository = require("devdocs.infrastructure.repositories.locks_repository")
    local buffer = require("devdocs.infrastructure.adapters.buffer")

    usecase.show(repository, locks_repository, snacks_picker, buffer, id)
  end
})
