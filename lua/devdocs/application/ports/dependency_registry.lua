---@class DependencyRegistry
---@field documentations_request fun(): DocumentationsProviderPort
---@field documents_request fun(): DocumentsProviderPort
---@field entries_request fun(): EntriesProviderPort
---@field registries_request fun(): RegistriesProviderPort
---@field documentations_repository fun(): DocumentationsPersistencePort
---@field documents_repository fun(): DocumentsPersistencePort
---@field entries_repository fun(): EntriesPersistencePort
---@field locks_repository fun(): LocksPersistencePort
---@field registries_repository fun(): RegistriesPersistencePort
---@field picker fun(): SelectorPort
---@field buffer fun(): RendererPort
local M = {}

return M
