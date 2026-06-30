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

  local mock_provider
  local mock_repository
  local mock_registries_repository
  local mock_entries_provider
  local mock_entries_repository
  local mock_locks_repository
  local mock_picker
  local mock_buffer

  before_each(function()
    saved_doc_args = nil
    saved_lock_args = nil
    entries_install_args = nil
    picker_registries_args = nil
    picker_locks_args = nil
    picker_entries_args = nil
    log_error_message = nil
    buffer_calls = {}

    mock_provider = { find_async = function() end }
    mock_repository = { save_async = function() end, find = function() end }
    mock_registries_repository = { list = function() end }
    mock_entries_provider = {}
    mock_entries_repository = {}
    mock_locks_repository = {
      save = function() end,
      list = function()
        return {}
      end,
    }
    mock_picker = {
      registries = function() end,
      locks = function() end,
      entries = function() end,
    }
    mock_buffer = {
      create_scratch_buffer = function(lines, filetype)
        table.insert(buffer_calls, { lines = lines, filetype = filetype })
        return 42
      end,
    }

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function(msg)
        log_error_message = msg
      end,
    }

    package.loaded["devdocs.application.usecases.registries_usecase"] = {
      list = function()
        return { { slug = "lua~5.4", name = "Lua" }, { slug = "javascript", name = "JavaScript" } }
      end,
    }

    package.loaded["devdocs.application.usecases.entries_usecase"] = {
      install = function(slug)
        entries_install_args = { slug = slug }
      end,
      install_async = function(slug, on_done)
        entries_install_args = { slug = slug }
        if on_done then
          on_done()
        end
      end,
      find = function(id)
        return { { name = "Array", path = "array#section", type = "Method" } }
      end,
    }

    package.loaded["devdocs.application.ports.dependency_registry"] = {
      documentations_provider = function()
        return mock_provider
      end,
      documentations_repository = function()
        return mock_repository
      end,
      registries_repository = function()
        return mock_registries_repository
      end,
      entries_provider = function()
        return mock_entries_provider
      end,
      entries_repository = function()
        return mock_entries_repository
      end,
      locks_repository = function()
        return mock_locks_repository
      end,
      picker = function()
        return mock_picker
      end,
      buffer = function()
        return mock_buffer
      end,
    }

    package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
    usecase = require("devdocs.application.usecases.documentations_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.helpers.make_logged"] = nil
    package.loaded["devdocs.application.ports.dependency_registry"] = nil
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
    package.loaded["devdocs.application.usecases.entries_usecase"] = nil
    package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
  end)

  describe("install", function()
    it("fetches, saves doc, installs entries, and saves lock via picker callback", function()
      local mock_doc = { html = "<h1>Lua</h1>" }
      mock_provider = {
        find_async = function(slug, on_success)
          on_success(mock_doc)
        end,
      }
      mock_repository = {
        save_async = function(doc, slug, on_done)
          saved_doc_args = { doc = doc, slug = slug }
          on_done()
        end,
      }
      mock_locks_repository = {
        save = function(data)
          saved_lock_args = data
        end,
      }
      mock_picker = {
        registries = function(callback, registries)
          picker_registries_args = { callback = callback, registries = registries }
        end,
      }

      usecase.install()

      assert.is_not_nil(picker_registries_args)

      -- Simulate picker selecting the first registry
      local mock_registry = { slug = "lua~5.4", name = "Lua" }
      picker_registries_args.callback(mock_registry)

      assert.same({ doc = mock_doc, slug = "lua~5.4" }, saved_doc_args)
      assert.same({ id = "lua~5.4", name = "Lua" }, saved_lock_args)
      assert.is_not_nil(entries_install_args)
      assert.equals("lua~5.4", entries_install_args.slug)
    end)

    it("returns early when provider.find_async returns nil", function()
      mock_provider = {
        find_async = function(slug, on_success)
          on_success(nil)
        end,
      }
      mock_repository = {
        save_async = function()
          error("should not be called")
        end,
      }
      mock_locks_repository = {
        save = function()
          error("should not be called")
        end,
      }
      mock_picker = {
        registries = function(callback)
          callback({ slug = "lua~5.4", name = "Lua" })
        end,
      }

      usecase.install()
    end)

    it("delegates to picker when no id given", function()
      mock_provider = { find_async = function() end }
      mock_repository = { save_async = function() end }
      mock_picker = {
        registries = function(callback, registries)
          picker_registries_args = { callback = callback, registries = registries }
        end,
      }

      usecase.install()

      assert.is_not_nil(picker_registries_args)
      assert.equals(2, #picker_registries_args.registries)
    end)

    it("errors when registries list returns nil", function()
      package.loaded["devdocs.application.usecases.registries_usecase"] = {
        list = function()
          return nil
        end,
      }

      package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
      usecase = require("devdocs.application.usecases.documentations_usecase")

      usecase.install()

      assert.equals("Registries not found!", log_error_message)
    end)

    it("notifies user when installation starts", function()
      local info_messages = {}
      package.loaded["devdocs.application.usecases.log_usecase"].info = function(msg)
        table.insert(info_messages, msg)
      end
      package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
      usecase = require("devdocs.application.usecases.documentations_usecase")

      mock_provider = { find_async = function() end }
      mock_repository = { save_async = function() end }
      mock_picker = {
        registries = function(callback)
          callback({ slug = "lua~5.4", name = "Lua" })
        end,
      }

      usecase.install()

      assert.equals("Installing Lua documentation...", info_messages[1])
    end)
  end)

  describe("show", function()
    it("delegates to picker.locks when no id given", function()
      mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      mock_picker = {
        locks = function(callback, locks)
          picker_locks_args = { callback = callback, locks = locks }
        end,
      }

      usecase.show()

      assert.is_not_nil(picker_locks_args)
      assert.equals(1, #picker_locks_args.locks)
    end)

    it("locks callback fetches entries and delegates to picker.entries", function()
      mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      mock_picker = {
        locks = function(callback)
          callback({ id = "lua~5.4", name = "Lua" })
        end,
        entries = function(callback, id, entries)
          picker_entries_args = { callback = callback, id = id, entries = entries }
        end,
      }

      usecase.show()

      assert.is_not_nil(picker_entries_args)
      assert.equals("lua~5.4", picker_entries_args.id)
      assert.equals(1, #picker_entries_args.entries)
    end)

    it("entry callback reads document and creates buffer", function()
      mock_repository = {
        find = function()
          return "# Lua\n\nContent here"
        end,
      }
      mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      mock_picker = {
        locks = function(callback)
          callback({ id = "lua~5.4", name = "Lua" })
        end,
        entries = function(callback)
          callback({ name = "Array", path = "array#section" })
        end,
      }

      usecase.show()

      assert.equals(1, #buffer_calls)
      assert.same({ "# Lua", "", "Content here" }, buffer_calls[1].lines)
      assert.equals("markdown", buffer_calls[1].filetype)
    end)

    it("locks callback errors when entries not found", function()
      package.loaded["devdocs.application.usecases.entries_usecase"] = {
        install = function() end,
        find = function()
          return nil
        end,
      }

      package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
      usecase = require("devdocs.application.usecases.documentations_usecase")

      mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      mock_picker = {
        locks = function(callback)
          callback({ id = "lua~5.4", name = "Lua" })
        end,
        entries = function()
          error("should not be called")
        end,
      }

      usecase.show()

      assert.is_not_nil(log_error_message)
    end)

    it("enriches locks with version, db_size, and doc_count", function()
      package.loaded["devdocs.application.usecases.registries_usecase"] = {
        list = function()
          return {
            { slug = "lua~5.4", name = "Lua", version = "5.4", db_size = 13002342 },
          }
        end,
      }
      package.loaded["devdocs.application.usecases.entries_usecase"] = {
        find = function()
          return { { name = "A" }, { name = "B" }, { name = "C" } }
        end,
      }
      package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
      usecase = require("devdocs.application.usecases.documentations_usecase")

      mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua", installed_at = "2026-04-13T00:45:51+0100" } }
        end,
      }
      mock_picker = {
        locks = function(callback, locks)
          picker_locks_args = { callback = callback, locks = locks }
        end,
      }

      usecase.show()

      assert.is_not_nil(picker_locks_args)
      local item = picker_locks_args.locks[1]
      assert.equals("5.4", item.version)
      assert.equals(13002342, item.db_size)
      assert.equals(3, item.doc_count)
      assert.equals("2026-04-13T00:45:51+0100", item.installed_at)
    end)

    it("still yields an item when no registry matches the lock", function()
      package.loaded["devdocs.application.usecases.registries_usecase"] = {
        list = function()
          return {}
        end,
      }
      package.loaded["devdocs.application.usecases.entries_usecase"] = {
        find = function()
          return {}
        end,
      }
      package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
      usecase = require("devdocs.application.usecases.documentations_usecase")

      mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua", installed_at = "2026-04-13T00:45:51+0100" } }
        end,
      }
      mock_picker = {
        locks = function(callback, locks)
          picker_locks_args = { callback = callback, locks = locks }
        end,
      }

      usecase.show()

      local item = picker_locks_args.locks[1]
      assert.equals("Lua", item.name)
      assert.is_nil(item.version)
      assert.is_nil(item.db_size)
      assert.equals(0, item.doc_count)
    end)
  end)
end)
