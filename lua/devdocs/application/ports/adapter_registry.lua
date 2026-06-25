---@class AdapterRegistry
---@field documentations_request fun(): DocumentationsRequestPort
---@field documents_request fun(): DocumentsRequestPort
---@field entries_request fun(): EntriesRequestPort
---@field registries_request fun(): RegistriesRequestPort
---@field documentations_repository fun(): DocumentationsRepositoryPort
---@field documents_repository fun(): DocumentsRepositoryPort
---@field entries_repository fun(): EntriesRepositoryPort
---@field locks_repository fun(): LocksRepositoryPort
---@field registries_repository fun(): RegistriesRepositoryPort
---@field picker fun(): PickerPort
---@field buffer fun(): BufferPort
local M = {}

return M
