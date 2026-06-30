local assert = require("luassert")

describe("entries_provider", function()
  local provider

  before_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
    }
    package.loaded["devdocs.infrastructure.external.providers.entries_provider"] = nil
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.external.clients.http_client"] = nil
    package.loaded["devdocs.infrastructure.external.providers.entries_provider"] = nil
  end)

  describe("list_async", function()
    it("calls http_client.get_async and passes transformed entries to on_success", function()
      local transformed = { { name = "Array", path = "array", type = "Method", slug = "lua~5.4" } }

      package.loaded["devdocs.infrastructure.external.clients.http_client"] = {
        get_async = function(url, callback)
          callback({
            body = '{"entries": [{"name": "Array", "path": "array", "type": "Method"}], "types": [{"name": "Method", "slug": "lua~5.4"}]}',
          })
        end,
      }

      provider = require("devdocs.infrastructure.external.providers.entries_provider")
      local result
      provider.list_async("lua~5.4", function(r) result = r end)

      assert.same(transformed, result)
    end)

    it("passes nil to on_success when body decodes to nil", function()
      package.loaded["devdocs.infrastructure.external.clients.http_client"] = {
        get_async = function(_, callback)
          callback({ body = "null" })
        end,
      }

      provider = require("devdocs.infrastructure.external.providers.entries_provider")
      local result = "not_called"
      provider.list_async("lua~5.4", function(r) result = r end)

      assert.is_nil(result)
    end)

    it("asserts on non-string slug", function()
      provider = require("devdocs.infrastructure.external.providers.entries_provider")
      assert.has_error(function() provider.list_async(123, function() end) end)
    end)
  end)
end)
