local registry = require("devdocs.application.ports.dependency_registry")

local modules = {
  documentations_request = "devdocs.infrastructure.requests.documentations_request",
  documents_request = "devdocs.infrastructure.requests.documents_request",
  entries_request = "devdocs.infrastructure.requests.entries_request",
  registries_request = "devdocs.infrastructure.requests.registries_request",
  documentations_repository = "devdocs.infrastructure.repositories.documentations_repository",
  documents_repository = "devdocs.infrastructure.repositories.documents_repository",
  entries_repository = "devdocs.infrastructure.repositories.entries_repository",
  locks_repository = "devdocs.infrastructure.repositories.locks_repository",
  registries_repository = "devdocs.infrastructure.repositories.registeries_repository",
  picker = "devdocs.infrastructure.pickers.snacks_picker",
  buffer = "devdocs.infrastructure.editor.buffer",
}

for name, module in pairs(modules) do
  registry[name] = function()
    return require(module)
  end
end
