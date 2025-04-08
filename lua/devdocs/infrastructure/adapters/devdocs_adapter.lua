---@class IDevdocsAdapter
---@field transform_entries fun(content: any, slug: string): EntryModel[] | nil
---@field transform_documentations fun(content: any): EntryModel[] | nil

---@type IDevdocsAdapter
return {
  transform_entries = function(content, slug)
    assert(type(content) ~= "nil", "content param is required")
    assert(type(slug) == "string", "slug must be a string")

    return vim.tbl_map(function(item)
      local result = vim.tbl_filter(function(type)
        return item.type == type.name
      end, content.types)

      local type = result[1] or {}

      return vim.tbl_extend("force", item, { slug = type.slug })
    end, content.entries)
  end,

  transform_documentations = function(content)
    assert(type(content) ~= "nil", "content param is required")

    local result = {}
    for key, value in pairs(content) do
      result[key] = value
    end

    return result
  end
}
