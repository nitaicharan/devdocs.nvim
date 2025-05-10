---@class IDocumentatiosUi
---@field install fun(slug: string?)
---@field show fun(slug: string?)

---@type IDocumentatiosUi
return {
  install = function(id)
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local usecase = require("devdocs.application.usecases.documentations_usecase")
    local request = require("devdocs.infrastructure.requests.documentations_request")
    local repository = require("devdocs.infrastructure.repositories.documentations_repository")
    local entries_request = require("devdocs.infrastructure.requests.entries_request")
    local entries_repository = require("devdocs.infrastructure.repositories.entries_repository")
    local snacks_picker = require("devdocs.infrastructure.pickers.snacks_picker")
    local registeries_repository = require("devdocs.infrastructure.repositories.registeries_repository")

    log_usecase.debug("[documentations_ui->install]:" .. vim.inspect({ id = id }))

    local documentation = usecase.install(
      request,
      repository,
      registeries_repository,
      entries_request,
      entries_repository,
      snacks_picker,
      id
    )

    if documentation == nil then
      return
    end
  end,

  show = function(name)
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local usecase = require("devdocs.application.usecases.documentations_usecase")
    local repository = require("devdocs.infrastructure.repositories.documentations_repository")
    local snacks_picker = require("devdocs.infrastructure.pickers.snacks_picker")

    log_usecase.debug("[documentations_ui->show]:" .. vim.inspect({ id = name }))

    usecase.show(repository, snacks_picker, name)
  end
}
