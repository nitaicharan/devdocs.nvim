local assert = require("luassert")

describe("entries_request", function()
  local request

  before_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
    }
    package.loaded["devdocs.infrastructure.requests.entries_request"] = nil
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.clients.http_client"] = nil
    package.loaded["devdocs.infrastructure.adapters.devdocs_adapter"] = nil
    package.loaded["devdocs.infrastructure.requests.entries_request"] = nil
  end)

  describe("list_async", function()
    it("calls http_client.get_async and passes transformed entries to on_success", function()
      local transformed = { { name = "Array", path = "array", type = "Method", slug = "lua~5.4" } }

      package.loaded["devdocs.infrastructure.clients.http_client"] = {
        get_async = function(url, callback)
          callback({ body = '{"entries": []}' })
        end,
      }
      package.loaded["devdocs.infrastructure.adapters.devdocs_adapter"] = {
        transform_entries = function() return transformed end,
      }

      request = require("devdocs.infrastructure.requests.entries_request")
      local result
      request.list_async("lua~5.4", function(r) result = r end)

      assert.same(transformed, result)
    end)

    it("passes nil to on_success when body decodes to nil", function()
      package.loaded["devdocs.infrastructure.clients.http_client"] = {
        get_async = function(_, callback)
          callback({ body = "null" })
        end,
      }
      package.loaded["devdocs.infrastructure.adapters.devdocs_adapter"] = {
        transform_entries = function() error("should not be called") end,
      }

      request = require("devdocs.infrastructure.requests.entries_request")
      local result = "not_called"
      request.list_async("lua~5.4", function(r) result = r end)

      assert.is_nil(result)
    end)

    it("asserts on non-string slug", function()
      request = require("devdocs.infrastructure.requests.entries_request")
      assert.has_error(function() request.list_async(123, function() end) end)
    end)
  end)
end)
