local make_logged = require("devdocs.application.helpers.make_logged")

local units = { "B", "KB", "MB", "GB", "TB" }

local M = {
  ---@param n number|nil byte count
  ---@return string|nil human-readable size, or nil when n is nil
  format = function(n)
    if n == nil then
      return nil
    end

    local size = n
    local idx = 1
    while size >= 1024 and idx < #units do
      size = size / 1024
      idx = idx + 1
    end

    if idx == 1 then
      return string.format("%d %s", size, units[idx])
    end

    return string.format("%.1f %s", size, units[idx])
  end,
}

return make_logged("utils/bytes_util", M)
