---@class SnacksPicker: IPicker

---@type SnacksPicker
return {
  entries = function(callback, id, entries)
    assert(type(callback) ~= "nil", "callback param is required")
    assert(type(entries) == "table", "entries must be a table")

    local log_usecase = require("devdocs.application.usecases.log_usecase")

    local snacks = require("snacks")

    local items = {}
    for idx, item in ipairs(entries) do
      local text = string.format("[%s]: %s", id, item.name)
      local result = vim.tbl_extend("force", item, { idx = idx, text = text })
      table.insert(items, result)
    end

    snacks.picker.pick({
      source = 'select',
      items = items,
      format = "text",
      actions = {
        confirm = function(picker, item)
          picker:close()

          log_usecase.debug("[snacks_picker->entries]:" .. vim.inspect({ item = item }))

          callback(item)
        end,
      },
      preview = "none",
    })
  end,
  registries = function(callback, registries)
    assert(type(callback) ~= "nil", "callback param is required")
    assert(type(registries) == "table", "registries must be a table")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local snacks = require("snacks")

    local items = {}
    for idx, item in ipairs(registries) do
      local text = string.format("[%s] version:%s", item.name, item.version)
      local result = vim.tbl_extend("force", item, { idx = idx, text = text })
      table.insert(items, result)
    end

    snacks.picker.pick({
      source = 'select',
      items = items,
      format = "text",
      actions = {
        confirm = function(picker, item)
          picker:close()

          log_usecase.debug("[snacks_picker->confirm]:" .. vim.inspect({ slug = item.slug }))

          callback(item)
        end,
      },
      preview = "none",
    })
  end,
  locks = function(callback, models)
    assert(type(callback) ~= "nil", "callback param is required")
    assert(type(models) == "table", "models must be a table")

    local log_usecase = require("devdocs.application.usecases.log_usecase")
    local snacks = require("snacks")

    local items = {}
    for idx, item in ipairs(models) do
      local text = string.format("[%s]: installed:%s updated:%s", item.name, item.installed_at, item.updated_at)
      local result = vim.tbl_extend("force", item, { idx = idx, text = text })
      table.insert(items, result)
    end

    snacks.picker.pick({
      source = 'select',
      items = items,
      format = "text",
      actions = {
        confirm = function(picker, item)
          picker:close()

          log_usecase.debug("[snacks_picker->entries]:" .. vim.inspect({ item = item }))

          callback(item)
        end,
      },
      preview = "none",
    })
  end
}
