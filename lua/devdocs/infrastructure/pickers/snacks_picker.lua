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
      local name = string.format("[%s]: %s", id, item.name)
      table.insert(items, { idx = idx, text = name, path = item.path })
    end

    snacks.picker.pick({
      source = 'select',
      items = items,
      format = "text",
      actions = {
        confirm = function(picker, item)
          picker:close()

          log_usecase.debug("[snacks_picker->entries]:" .. vim.inspect({ path = item.path }))

          callback(item.path)
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
      local name = string.format(
        "[%s] version:%s slug:%s release:%s",
        (item.name and item.name ~= "" and item.name) or "none",
        (item.version and item.version ~= "" and item.version) or "none",
        (item.slug and item.slug ~= "" and item.slug) or "none",
        (item.release and item.release ~= "" and item.release) or "none"
      )

      table.insert(items, { idx = idx, text = name, slug = item.slug })
    end

    snacks.picker.pick({
      source = 'select',
      items = items,
      format = "text",
      actions = {
        confirm = function(picker, item)
          picker:close()

          log_usecase.debug("[snacks_picker->registries]:" .. vim.inspect({ slug = item.slug }))

          callback(item.slug)
        end,
      },
      preview = "none",
    })
  end
}
