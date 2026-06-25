local make_logged = require("devdocs.application.helpers.make_logged")

local M = {}

---@param id string?
M.install = function(id)
  local usecase = require("devdocs.application.usecases.documentations_usecase")
  usecase.install(id)
end

---@param id string?
M.show = function(id)
  local usecase = require("devdocs.application.usecases.documentations_usecase")
  usecase.show(id)
end

return make_logged("uis/documentations", M)
