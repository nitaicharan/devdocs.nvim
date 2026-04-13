---@class SnacksPicker: IPicker

local make_logged_helper = require("devdocs.application.helpers.make_logged")
local make_logged = make_logged_helper.make_logged

---@type SnacksPicker
return make_logged("snacks_picker", {
  entries = function(callback, id, entries)
    assert(type(callback) ~= "nil", "callback param is required")
    assert(type(entries) == "table", "entries must be a table")

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
          callback(item)
        end,
      },
      preview = "none",
    })
  end,
  registries = function(callback, registries)
    assert(type(callback) ~= "nil", "callback param is required")
    assert(type(registries) == "table", "registries must be a table")

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
          callback(item)
        end,
      },
      preview = "none",
    })
  end,
  locks = function(callback, models)
    assert(type(callback) ~= "nil", "callback param is required")
    assert(type(models) == "table", "models must be a table")

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
          callback(item)
        end,
      },
      preview = "none",
    })
  end
})
