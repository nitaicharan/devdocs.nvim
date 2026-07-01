local make_logged = require("devdocs.application.helpers.make_logged")

-- Snacks format segments shared by the locks/registries rows:
-- icon + highlighted name + dimmed, "·"-joined metadata.
local function render_row(name, meta)
  return {
    { "󱔘 ", "SnacksPickerIcon" },
    { name, "SnacksPickerLabel" },
    { "  " .. table.concat(meta, " · "), "Comment" },
  }
end

---@type SelectorPort
local M = {
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
    local relative_time = require("devdocs.infrastructure.utils.relative_time_util")
    local bytes_util = require("devdocs.infrastructure.utils.bytes_util")

    local items = {}
    for idx, item in ipairs(registries) do
      local result = vim.tbl_extend("force", item, { idx = idx, text = item.name })
      table.insert(items, result)
    end

    snacks.picker.pick({
      source = 'select',
      items = items,
      format = function(item)
        local meta = {}
        if item.version and item.version ~= "" then
          table.insert(meta, "v" .. item.version)
        end
        local size = bytes_util.format(item.db_size)
        if size then
          table.insert(meta, size)
        end
        if item.mtime and item.mtime > 0 then
          table.insert(meta, "updated " .. relative_time.from_epoch(item.mtime))
        end
        return render_row(item.name, meta)
      end,
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
    local relative_time = require("devdocs.infrastructure.utils.relative_time_util")
    local bytes_util = require("devdocs.infrastructure.utils.bytes_util")

    local items = {}
    for idx, item in ipairs(models) do
      -- keep `text` = name so Snacks fuzzy-matching still filters by doc name
      local result = vim.tbl_extend("force", item, { idx = idx, text = item.name })
      table.insert(items, result)
    end

    snacks.picker.pick({
      source = 'select',
      items = items,
      format = function(item)
        local meta = {}
        if item.version and item.version ~= "" then
          table.insert(meta, "v" .. item.version)
        end
        if item.doc_count and item.doc_count > 0 then
          table.insert(meta, item.doc_count .. " entries")
        end
        local size = bytes_util.format(item.db_size)
        if size then
          table.insert(meta, size)
        end
        table.insert(meta, "installed " .. relative_time.format(item.installed_at))
        return render_row(item.name, meta)
      end,
      actions = {
        confirm = function(picker, item)
          picker:close()
          callback(item)
        end,
      },
      preview = "none",
    })
  end,
}

return make_logged("pickers/snacks_picker", M)
