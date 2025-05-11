---@class IFilesUtil
---@field write fun(path: string, content: any)
---@field read fun(path: string): unknown
---@field joinpath fun(...: string): string
---@field mkdir fun(path: string): string

---@type IFilesUtil
return {
  write = function(path, content)
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local plenary = require("plenary.path"):new(path)

    log_usecase.debug("[files_util->write]:" .. vim.inspect({ path = path }))

    local folder = plenary:parent()
    if not plenary:exists() then
      folder:mkdir({ parents = true })
    end

    plenary:write(vim.fn.json_encode(content), "w")
  end,

  read = function(path)
    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local plenary = require("plenary.path"):new(path)

    log_usecase.debug("[files_util->read]:" .. vim.inspect({ path = path }))

    if not plenary:exists() then
      return nil
    end

    local data = plenary:read()
    if data == nil then
      return nil
    end

    return vim.fn.json_decode(data)
  end,

  joinpath = function(...)
    local plenary = require("plenary.path"):new()

    local result = plenary:joinpath(...)
    return tostring(result)
  end,

  mkdir = function(path)
    assert(type(path) == "string", "path must be a string")

    local plenary = require("plenary.path"):new(path)

    plenary:mkdir({ parents = true })
  end,
}
