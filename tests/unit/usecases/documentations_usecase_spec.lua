local assert = require("luassert")

describe("documentations_usecase", function()
  local usecase
  local saved_doc_args
  local saved_lock_args
  local entries_install_args
  local picker_registries_args
  local picker_locks_args
  local picker_entries_args
  local log_error_message
  local buffer_calls

  before_each(function()
    saved_doc_args = nil
    saved_lock_args = nil
    entries_install_args = nil
    picker_registries_args = nil
    picker_locks_args = nil
    picker_entries_args = nil
    log_error_message = nil
    buffer_calls = {}

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function(msg) log_error_message = msg end,
    }

    package.loaded["devdocs.application.usecases.registries_usecase"] = {
      list = function()
        return { { slug = "lua~5.4", name = "Lua" }, { slug = "javascript", name = "JavaScript" } }
      end,
    }

    package.loaded["devdocs.application.usecases.entries_usecase"] = {
      install = function(request, repository, slug)
        entries_install_args = { request = request, repository = repository, slug = slug }
      end,
      find = function(id)
        return { { name = "Array", path = "array#section", type = "Method" } }
      end,
    }

    package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
    usecase = require("devdocs.application.usecases.documentations_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.helpers.make_logged"] = nil
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
    package.loaded["devdocs.application.usecases.entries_usecase"] = nil
    package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
  end)

  describe("install", function()
    local mock_entries_request
    local mock_entries_repository

    before_each(function()
      mock_entries_request = { list = function() end }
      mock_entries_repository = { save = function() end }
    end)

    it("fetches, saves doc, installs entries, and saves lock via picker callback", function()
      local mock_doc = { html = "<h1>Lua</h1>" }
      local mock_request = { find = function() return mock_doc end }
      local mock_repository = {
        save = function(doc, slug)
          saved_doc_args = { doc = doc, slug = slug }
        end,
      }
      local mock_registries_repository = { list = function() end }
      local mock_locks_repository = {
        save = function(data) saved_lock_args = data end,
      }
      local mock_picker = {
        registries = function(callback, registries)
          picker_registries_args = { callback = callback, registries = registries }
        end,
      }

      usecase.install(
        mock_request, mock_repository, mock_registries_repository,
        mock_entries_request, mock_entries_repository, mock_locks_repository,
        mock_picker
      )

      assert.is_not_nil(picker_registries_args)

      -- Simulate picker selecting the first registry
      local mock_registry = { slug = "lua~5.4", name = "Lua" }
      picker_registries_args.callback(mock_registry)

      assert.same({ doc = mock_doc, slug = "lua~5.4" }, saved_doc_args)
      assert.same({ id = "lua~5.4", name = "Lua" }, saved_lock_args)
      assert.is_not_nil(entries_install_args)
      assert.equals("lua~5.4", entries_install_args.slug)
    end)

    it("returns early when request.find returns nil", function()
      local mock_request = { find = function() return nil end }
      local mock_repository = {
        save = function() error("should not be called") end,
      }
      local mock_registries_repository = { list = function() end }
      local mock_locks_repository = {
        save = function() error("should not be called") end,
      }
      local mock_picker = {
        registries = function(callback)
          callback({ slug = "lua~5.4", name = "Lua" })
        end,
      }

      usecase.install(
        mock_request, mock_repository, mock_registries_repository,
        mock_entries_request, mock_entries_repository, mock_locks_repository,
        mock_picker
      )
    end)

    it("delegates to picker when no id given", function()
      local mock_request = { find = function() end }
      local mock_repository = { save = function() end }
      local mock_registries_repository = { list = function() end }
      local mock_locks_repository = { save = function() end }
      local mock_picker = {
        registries = function(callback, registries)
          picker_registries_args = { callback = callback, registries = registries }
        end,
      }

      usecase.install(
        mock_request, mock_repository, mock_registries_repository,
        mock_entries_request, mock_entries_repository, mock_locks_repository,
        mock_picker
      )

      assert.is_not_nil(picker_registries_args)
      assert.equals(2, #picker_registries_args.registries)
    end)

    it("errors when registries list returns nil", function()
      package.loaded["devdocs.application.usecases.registries_usecase"] = {
        list = function() return nil end,
      }

      package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
      usecase = require("devdocs.application.usecases.documentations_usecase")

      local mock_request = { find = function() end }
      local mock_repository = { save = function() end }
      local mock_registries_repository = { list = function() end }
      local mock_locks_repository = { save = function() end }
      local mock_picker = { registries = function() error("should not be called") end }

      usecase.install(
        mock_request, mock_repository, mock_registries_repository,
        mock_entries_request, mock_entries_repository, mock_locks_repository,
        mock_picker
      )

      assert.equals("Registries not found!", log_error_message)
    end)

    it("asserts on nil request", function()
      assert.has_error(function()
        usecase.install(nil, {}, {}, {}, {}, {}, {})
      end)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.install({}, nil, {}, {}, {}, {}, {})
      end)
    end)

    it("asserts on nil picker", function()
      assert.has_error(function()
        usecase.install({}, {}, {}, {}, {}, {}, nil)
      end)
    end)
  end)

  describe("show", function()
    local mock_buffer

    before_each(function()
      mock_buffer = {
        create_scratch_buffer = function(lines, filetype)
          table.insert(buffer_calls, { lines = lines, filetype = filetype })
          return 42
        end,
      }
    end)

    it("delegates to picker.locks when no id given", function()
      local mock_repository = { find = function() end }
      local mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      local mock_picker = {
        locks = function(callback, locks)
          picker_locks_args = { callback = callback, locks = locks }
        end,
      }

      usecase.show(mock_repository, mock_locks_repository, mock_picker, mock_buffer)

      assert.is_not_nil(picker_locks_args)
      assert.equals(1, #picker_locks_args.locks)
    end)

    it("locks callback fetches entries and delegates to picker.entries", function()
      local mock_repository = { find = function() end }
      local mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      local mock_picker = {
        locks = function(callback)
          callback({ id = "lua~5.4", name = "Lua" })
        end,
        entries = function(callback, id, entries)
          picker_entries_args = { callback = callback, id = id, entries = entries }
        end,
      }

      usecase.show(mock_repository, mock_locks_repository, mock_picker, mock_buffer)

      assert.is_not_nil(picker_entries_args)
      assert.equals("lua~5.4", picker_entries_args.id)
      assert.equals(1, #picker_entries_args.entries)
    end)

    it("entry callback reads document and creates buffer", function()
      local mock_repository = {
        find = function() return "# Lua\n\nContent here" end,
      }
      local mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      local mock_picker = {
        locks = function(callback)
          callback({ id = "lua~5.4", name = "Lua" })
        end,
        entries = function(callback)
          callback({ name = "Array", path = "array#section" })
        end,
      }

      usecase.show(mock_repository, mock_locks_repository, mock_picker, mock_buffer)

      assert.equals(1, #buffer_calls)
      assert.same({ "# Lua", "", "Content here" }, buffer_calls[1].lines)
      assert.equals("markdown", buffer_calls[1].filetype)
    end)

    it("locks callback errors when entries not found", function()
      package.loaded["devdocs.application.usecases.entries_usecase"] = {
        install = function() end,
        find = function() return nil end,
      }

      package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
      usecase = require("devdocs.application.usecases.documentations_usecase")

      local mock_repository = { find = function() end }
      local mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      local mock_picker = {
        locks = function(callback)
          callback({ id = "lua~5.4", name = "Lua" })
        end,
        entries = function() error("should not be called") end,
      }

      usecase.show(mock_repository, mock_locks_repository, mock_picker, mock_buffer)

      assert.is_not_nil(log_error_message)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.show(nil, {}, {}, mock_buffer)
      end)
    end)

    it("asserts on nil buffer", function()
      assert.has_error(function()
        usecase.show({}, {}, {}, nil)
      end)
    end)
  end)
end)
