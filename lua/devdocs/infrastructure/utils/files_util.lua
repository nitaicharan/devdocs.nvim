local make_logged = require("devdocs.application.helpers.make_logged")

local M = {
  ---@param path string
  ---@param content any
  write = function(path, content)
    local plenary = require("plenary.path"):new(path)

    local folder = plenary:parent()
    if not plenary:exists() then
      folder:mkdir({ parents = true })
    end

    plenary:write(vim.fn.json_encode(content), "w")
  end,

  ---@param path string
  ---@return unknown
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

  ---@param ... string
  ---@return string
  joinpath = function(...)
    local plenary = require("plenary.path"):new()

    local result = plenary:joinpath(...)
    return tostring(result)
  end,

  ---@param path string
  mkdir = function(path)
    assert(type(path) == "string", "path must be a string")

    local plenary = require("plenary.path"):new(path)

    plenary:mkdir({ parents = true })
  end
}

return make_logged("utils/files_util", M)
