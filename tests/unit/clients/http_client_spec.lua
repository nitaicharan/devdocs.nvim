local assert = require("luassert")

describe("http_client", function()
  local http_client

  before_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
    }
    package.loaded["devdocs.infrastructure.clients.http_client"] = nil
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.clients.http_client"] = nil
    package.loaded["plenary.curl"] = nil
  end)

  describe("get_async", function()
    it("calls plenary.curl.get with callback in options", function()
      local captured_url, captured_options
      package.loaded["plenary.curl"] = {
        get = function(url, options)
          captured_url = url
          captured_options = options
        end,
      }

      http_client = require("devdocs.infrastructure.clients.http_client")
      local cb = function() end
      http_client.get_async("https://example.com", cb)

      assert.equals("https://example.com", captured_url)
      assert.is_function(captured_options.callback)
    end)

    it("merges additional options with callback", function()
      local captured_options
      package.loaded["plenary.curl"] = {
        get = function(_, options) captured_options = options end,
      }

      http_client = require("devdocs.infrastructure.clients.http_client")
      http_client.get_async("https://example.com", function() end, { headers = { ["X-Test"] = "1" } })

      assert.equals("1", captured_options.headers["X-Test"])
      assert.is_function(captured_options.callback)
    end)

    it("asserts on non-string url", function()
      http_client = require("devdocs.infrastructure.clients.http_client")
      assert.has_error(function() http_client.get_async(123, function() end) end)
    end)

    it("asserts on non-function callback", function()
      http_client = require("devdocs.infrastructure.clients.http_client")
      assert.has_error(function() http_client.get_async("https://example.com", "not a function") end)
    end)
  end)
end)
