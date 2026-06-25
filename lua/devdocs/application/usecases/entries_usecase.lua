local make_logged = require("devdocs.application.helpers.make_logged")

local M = {}

---@param id string
M.install = function(id)
  assert(type(id) == "string", "id must be a string")

  local ports = require("devdocs.application.ports.adapter_registry")
  local request = ports.entries_request()
  local repository = ports.entries_repository()

  local entries = request.list(id)
  if entries == nil then
    return
  end

  repository.save(entries, id)
end

---@param id string
---@param on_done? fun()
M.install_async = function(id, on_done)
  assert(type(id) == "string", "id must be a string")

  local ports = require("devdocs.application.ports.adapter_registry")
  local request = ports.entries_request()
  local repository = ports.entries_repository()

  request.list_async(id, function(entries)
    if entries == nil then
      if on_done then on_done() end
      return
    end
    repository.save(entries, id)
    if on_done then on_done() end
  end)
end

---@param id string
---@return EntryModel[] | nil
M.find = function(id)
  assert(type(id) == "string", "id must be a string")

  local ports = require("devdocs.application.ports.adapter_registry")
  local repository = ports.entries_repository()

  return repository.find(id)
end

return make_logged("usecases/entries", M)
