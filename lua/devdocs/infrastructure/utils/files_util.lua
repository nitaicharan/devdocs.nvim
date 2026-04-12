---@class IFilesUtil
---@field write fun(path: string, content: any)
---@field read fun(path: string): unknown
---@field joinpath fun(...: string): string
---@field mkdir fun(path: string): string

local make_logged = require("devdocs.application.helpers.make_logged")

---@type IFilesUtil
return make_logged("files_util", {
  write = function(path, content)
    local plenary = require("plenary.path"):new(path)

    local folder = plenary:parent()
    if not plenary:exists() then
      folder:mkdir({ parents = true })
    end

    plenary:write(vim.fn.json_encode(content), "w")
  end,

  read = function(path)
    local plenary = require("plenary.path"):new(path)

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
})
