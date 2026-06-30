local assert = require("luassert")

describe("registries_usecase", function()
  local usecase
  local saved_data
  local mock_provider
  local mock_repository

  before_each(function()
    saved_data = nil
    mock_provider = { list = function() end }
    mock_repository = { list = function() return nil end, save = function() end }

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.application.ports.dependency_registry"] = {
      registries_provider = function() return mock_provider end,
      registries_repository = function() return mock_repository end,
    }

    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
    usecase = require("devdocs.application.usecases.registries_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.helpers.make_logged"] = nil
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.application.ports.dependency_registry"] = nil
    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
  end)

  describe("install", function()
    it("fetches and saves registry when not installed", function()
      local mock_data = { { slug = "lua", name = "Lua" } }
      mock_provider = { list = function() return mock_data end }
      mock_repository = {
        list = function() return nil end,
        save = function(data) saved_data = data end,
      }

      usecase.install()

      assert.same(mock_data, saved_data)
    end)

    it("skips fetch when registry already exists", function()
      mock_provider = { list = function() error("should not be called") end }
      mock_repository = {
        list = function() return { { slug = "lua" } } end,
        save = function() error("should not be called") end,
      }

      usecase.install()
    end)
  end)

  describe("list", function()
    it("returns repository result", function()
      local mock_data = { { slug = "lua", name = "Lua" } }
      mock_repository = { list = function() return mock_data end }

      local result = usecase.list()

      assert.same(mock_data, result)
    end)

    it("returns nil when repository has no data", function()
      mock_repository = { list = function() return nil end }

      local result = usecase.list()

      assert.is_nil(result)
    end)
  end)
end)
