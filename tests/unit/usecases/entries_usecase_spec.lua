local assert = require("luassert")

describe("entries_usecase", function()
  local usecase
  local saved_entries
  local saved_id

  before_each(function()
    saved_entries = nil
    saved_id = nil

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.infrastructure.repositories.entries_repository"] = {
      find = function(id) return { { name = "Array", path = "array", type = "Method", slug = id } } end,
    }

    package.loaded["devdocs.application.usecases.entries_usecase"] = nil
    usecase = require("devdocs.application.usecases.entries_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.helpers.make_logged"] = nil
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.repositories.entries_repository"] = nil
    package.loaded["devdocs.application.usecases.entries_usecase"] = nil
  end)

  describe("install", function()
    it("fetches and saves entries", function()
      local mock_entries = { { name = "Array", path = "array" } }
      local mock_request = { list = function() return mock_entries end }
      local mock_repository = {
        save = function(entries, id)
          saved_entries = entries
          saved_id = id
        end,
      }

      usecase.install(mock_request, mock_repository, "lua~5.4")

      assert.same(mock_entries, saved_entries)
      assert.equals("lua~5.4", saved_id)
    end)

    it("returns early when request returns nil", function()
      local mock_request = { list = function() return nil end }
      local mock_repository = {
        save = function() error("should not be called") end,
      }

      usecase.install(mock_request, mock_repository, "lua~5.4")
    end)

    it("asserts on nil request", function()
      assert.has_error(function()
        usecase.install(nil, {}, "lua~5.4")
      end)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.install({}, nil, "lua~5.4")
      end)
    end)

    it("asserts on non-string id", function()
      assert.has_error(function()
        usecase.install({}, {}, 123)
      end)
    end)
  end)

  describe("install_async", function()
    it("fetches and saves entries asynchronously", function()
      local mock_entries = { { name = "Array", path = "array" } }
      local mock_request = {
        list_async = function(slug, on_success) on_success(mock_entries) end,
      }
      local mock_repository = {
        save = function(entries, id)
          saved_entries = entries
          saved_id = id
        end,
      }
      local done_called = false

      usecase.install_async(mock_request, mock_repository, "lua~5.4", function()
        done_called = true
      end)

      assert.same(mock_entries, saved_entries)
      assert.equals("lua~5.4", saved_id)
      assert.is_true(done_called)
    end)

    it("calls on_done even when request returns nil", function()
      local mock_request = { list_async = function(_, on_success) on_success(nil) end }
      local mock_repository = { save = function() error("should not be called") end }
      local done_called = false

      usecase.install_async(mock_request, mock_repository, "lua~5.4", function()
        done_called = true
      end)

      assert.is_true(done_called)
    end)

    it("works without on_done callback", function()
      local mock_request = { list_async = function(_, on_success) on_success(nil) end }
      local mock_repository = { save = function() end }

      assert.has_no.errors(function()
        usecase.install_async(mock_request, mock_repository, "lua~5.4")
      end)
    end)

    it("asserts on nil request", function()
      assert.has_error(function()
        usecase.install_async(nil, {}, "lua~5.4")
      end)
    end)
  end)

  describe("find", function()
    it("returns entries from repository", function()
      local result = usecase.find("lua~5.4")

      assert.same({ { name = "Array", path = "array", type = "Method", slug = "lua~5.4" } }, result)
    end)

    it("returns nil when repository has no data", function()
      package.loaded["devdocs.infrastructure.repositories.entries_repository"] = {
        find = function() return nil end,
      }

      package.loaded["devdocs.application.usecases.entries_usecase"] = nil
      usecase = require("devdocs.application.usecases.entries_usecase")

      local result = usecase.find("nonexistent")

      assert.is_nil(result)
    end)

    it("asserts on non-string id", function()
      assert.has_error(function()
        usecase.find(123)
      end)
    end)
  end)
end)
