local assert = require("luassert")

describe("documentations_repository", function()
  local repository
  local written_files
  local converted_slugs

  before_each(function()
    written_files = {}
    converted_slugs = {}

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      error = function() end,
    }

    package.loaded["devdocs.infrastructure.clients.pandas_client"] = {
      html_to_markdown_async = function(html, on_success)
        table.insert(converted_slugs, html)
        on_success("# converted")
      end,
    }

    package.loaded["devdocs.infrastructure.utils.files_util"] = {
      joinpath = function(...) return table.concat({ ... }, "/") end,
      write = function(path, content)
        table.insert(written_files, { path = path, content = content })
      end,
    }

    package.loaded["devdocs.domain.defaults.setup_config"] = {
      plataform = "test",
    }

    package.loaded["devdocs.infrastructure.repositories.documentations_repository"] = nil
    repository = require("devdocs.infrastructure.repositories.documentations_repository")
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.clients.pandas_client"] = nil
    package.loaded["devdocs.infrastructure.utils.files_util"] = nil
    package.loaded["devdocs.domain.defaults.setup_config"] = nil
    package.loaded["devdocs.infrastructure.repositories.documentations_repository"] = nil
  end)

  describe("save_async", function()
    it("converts and writes all pages sequentially", function()
      local documentation = {
        ["page1"] = "<h1>Page 1</h1>",
        ["page2"] = "<h1>Page 2</h1>",
      }
      local done_called = false

      repository.save_async(documentation, "lua~5.4", function()
        done_called = true
      end)

      assert.is_true(done_called)
      assert.equals(2, #written_files)
      assert.equals(2, #converted_slugs)
    end)

    it("calls on_done with empty documentation", function()
      local done_called = false

      repository.save_async({}, "lua~5.4", function()
        done_called = true
      end)

      assert.is_true(done_called)
      assert.equals(0, #written_files)
    end)

    it("asserts on non-table documentation", function()
      assert.has_error(function()
        repository.save_async("not a table", "lua~5.4", function() end)
      end)
    end)

    it("asserts on non-string id", function()
      assert.has_error(function()
        repository.save_async({}, 123, function() end)
      end)
    end)
  end)
end)
