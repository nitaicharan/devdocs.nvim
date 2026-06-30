local assert = require("luassert")

describe("documentations_provider", function()
  local provider

  before_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
    }
    package.loaded["devdocs.infrastructure.external.providers.documentations_provider"] = nil
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.external.clients.http_client"] = nil
    package.loaded["devdocs.infrastructure.external.providers.documentations_provider"] = nil
  end)

  describe("find_async", function()
    it("calls http_client.get_async and passes the decoded body to on_success", function()
      package.loaded["devdocs.infrastructure.external.clients.http_client"] = {
        get_async = function(url, callback)
          callback({ body = '{"array": "<h1>Array</h1>"}' })
        end,
      }

      provider = require("devdocs.infrastructure.external.providers.documentations_provider")
      local result
      provider.find_async("lua~5.4", function(r) result = r end)

      assert.same({ array = "<h1>Array</h1>" }, result)
    end)

    it("passes nil to on_success when body decodes to nil", function()
      package.loaded["devdocs.infrastructure.external.clients.http_client"] = {
        get_async = function(_, callback)
          callback({ body = "null" })
        end,
      }

      provider = require("devdocs.infrastructure.external.providers.documentations_provider")
      local result = "not_called"
      provider.find_async("lua~5.4", function(r) result = r end)

      assert.is_nil(result)
    end)

    it("asserts on non-string slug", function()
      provider = require("devdocs.infrastructure.external.providers.documentations_provider")
      assert.has_error(function() provider.find_async(123, function() end) end)
    end)

    it("asserts on non-function callback", function()
      provider = require("devdocs.infrastructure.external.providers.documentations_provider")
      assert.has_error(function() provider.find_async("lua~5.4", "not a function") end)
    end)
  end)
end)
