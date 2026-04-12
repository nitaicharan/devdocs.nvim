local assert = require("luassert")

describe("registries_usecase", function()
  local usecase
  local saved_data

  before_each(function()
    saved_data = nil

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
    usecase = require("devdocs.application.usecases.registries_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
  end)

  describe("install", function()
    it("fetches and saves registry when not installed", function()
      local mock_data = { { slug = "lua", name = "Lua" } }
      local mock_request = { list = function() return mock_data end }
      local mock_repository = {
        list = function() return nil end,
        save = function(data) saved_data = data end,
      }

      usecase.install(mock_request, mock_repository)

      assert.same(mock_data, saved_data)
    end)

    it("skips fetch when registry already exists", function()
      local mock_request = { list = function() error("should not be called") end }
      local mock_repository = {
        list = function() return { { slug = "lua" } } end,
        save = function() error("should not be called") end,
      }

      usecase.install(mock_request, mock_repository)
    end)

    it("asserts on nil request", function()
      assert.has_error(function()
        usecase.install(nil, {})
      end)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.install({}, nil)
      end)
    end)
  end)

  describe("list", function()
    it("returns repository result", function()
      local mock_data = { { slug = "lua", name = "Lua" } }
      local mock_repository = { list = function() return mock_data end }

      local result = usecase.list(mock_repository)

      assert.same(mock_data, result)
    end)

    it("returns nil when repository has no data", function()
      local mock_repository = { list = function() return nil end }

      local result = usecase.list(mock_repository)

      assert.is_nil(result)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.list(nil)
      end)
    end)
  end)
end)
