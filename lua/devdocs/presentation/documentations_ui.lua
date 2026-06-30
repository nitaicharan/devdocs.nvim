local documentations_usecase = require("devdocs.application.usecases.documentations_usecase")
local make_logged = require("devdocs.application.helpers.make_logged")

local M = {
  ---@param id string?
  install = function(id)
    documentations_usecase.install(id)
  end,

  ---@param id string?
  show = function(id)
    documentations_usecase.show(id)
  end,
}

return make_logged("presentation/documentations_ui", M)
