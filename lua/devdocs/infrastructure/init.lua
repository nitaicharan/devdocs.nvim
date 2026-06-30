local registry = require("devdocs.application.ports.dependency_registry")

local modules = {
  documentations_provider = "devdocs.infrastructure.external.providers.documentations_provider",
  documents_provider = "devdocs.infrastructure.external.providers.documents_provider",
  entries_provider = "devdocs.infrastructure.external.providers.entries_provider",
  registries_provider = "devdocs.infrastructure.external.providers.registries_provider",
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
