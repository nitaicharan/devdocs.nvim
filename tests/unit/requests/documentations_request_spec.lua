local assert = require("luassert")

describe("documentations_request", function()
  local request

  before_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
    }
    package.loaded["devdocs.infrastructure.requests.documentations_request"] = nil
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.clients.http_client"] = nil
    package.loaded["devdocs.infrastructure.adapters.devdocs_adapter"] = nil
    package.loaded["devdocs.infrastructure.requests.documentations_request"] = nil
  end)

  describe("find_async", function()
    it("calls http_client.get_async and passes transformed result to on_success", function()
      local transformed = { { path = "array", html = "<h1>Array</h1>" } }

      package.loaded["devdocs.infrastructure.clients.http_client"] = {
        get_async = function(url, callback)
          callback({ body = '{"array": "<h1>Array</h1>"}' })
        end,
      }
      package.loaded["devdocs.infrastructure.adapters.devdocs_adapter"] = {
        transform_documentations = function() return transformed end,
      }

      request = require("devdocs.infrastructure.requests.documentations_request")
      local result
      request.find_async("lua~5.4", function(r) result = r end)

      assert.same(transformed, result)
    end)

    it("passes nil to on_success when body decodes to nil", function()
      package.loaded["devdocs.infrastructure.clients.http_client"] = {
        get_async = function(_, callback)
          callback({ body = "null" })
        end,
      }
      package.loaded["devdocs.infrastructure.adapters.devdocs_adapter"] = {
        transform_documentations = function() error("should not be called") end,
      }

      request = require("devdocs.infrastructure.requests.documentations_request")
      local result = "not_called"
      request.find_async("lua~5.4", function(r) result = r end)

      assert.is_nil(result)
    end)

    it("asserts on non-string slug", function()
      request = require("devdocs.infrastructure.requests.documentations_request")
      assert.has_error(function() request.find_async(123, function() end) end)
    end)

    it("asserts on non-function callback", function()
      request = require("devdocs.infrastructure.requests.documentations_request")
      assert.has_error(function() request.find_async("lua~5.4", "not a function") end)
    end)
  end)
end)
