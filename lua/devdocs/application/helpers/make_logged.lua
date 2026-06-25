local log_usecase = require("devdocs.application.usecases.log_usecase")

return function(module_name, module)
  return setmetatable({}, {
    __index = function(_, func_name)
      local original = module[func_name]

      if type(original) ~= "function" then
        return original
      end

      return function(...)
        log_usecase.debug(
          "[" .. module_name .. "->" .. func_name .. "]:" .. vim.inspect({ ... })
        )
        return original(...)
      end
    end,
  })
end
