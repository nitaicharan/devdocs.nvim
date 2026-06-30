---@class DependencyRegistry
---@field documentations_provider fun(): DocumentationsProviderPort
---@field documents_provider fun(): DocumentsProviderPort
---@field entries_provider fun(): EntriesProviderPort
---@field registries_provider fun(): RegistriesProviderPort
---@field documentations_repository fun(): DocumentationsPersistencePort
---@field documents_repository fun(): DocumentsPersistencePort
---@field entries_repository fun(): EntriesPersistencePort
---@field locks_repository fun(): LocksPersistencePort
---@field registries_repository fun(): RegistriesPersistencePort
---@field picker fun(): SelectorPort
---@field buffer fun(): RendererPort
local M = {}

return M
