---@class SnacksPicker: IPicker

---@type SnacksPicker
return {
  entries = function(callback, id, entries)
    assert(type(callback) ~= "nil", "entries param is required")
    assert(type(entries) == "table", "entries must be a table")

    local log_usecase = require("devdocs.application.usecases.log_usecase")

    local snacks = require("snacks")

    local items = {}
    for idx, entry in ipairs(entries) do
      local name = string.format("[%s]: %s", id, entry.name)
      table.insert(items, { idx = idx, text = name, path = entry.path })
    end

    snacks.picker.pick({
      source = 'select',
      items = items,
      format = "text",
      actions = {
        confirm = function(picker, item)
          picker:close()

          log_usecase.debug("[snacks_picker->show]:" .. vim.inspect({ item_path = item.path }))

          callback(item.path)
        end,
      },
      preview = "none",
    })
  end
}
