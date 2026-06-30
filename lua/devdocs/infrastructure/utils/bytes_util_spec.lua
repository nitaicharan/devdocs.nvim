local assert = require("luassert")

describe("bytes_util", function()
  local bytes_util

  before_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.infrastructure.utils.bytes_util"] = nil
    bytes_util = require("devdocs.infrastructure.utils.bytes_util")
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.utils.bytes_util"] = nil
  end)

  it("formats bytes as a whole number", function()
    assert.equals("512 B", bytes_util.format(512))
  end)

  it("formats kilobytes with one decimal", function()
    assert.equals("1.5 KB", bytes_util.format(1536))
  end)

  it("formats megabytes with one decimal", function()
    assert.equals("12.4 MB", bytes_util.format(13002342))
  end)

  it("formats gigabytes with one decimal", function()
    assert.equals("2.0 GB", bytes_util.format(2 * 1024 * 1024 * 1024))
  end)

  it("uses the largest unit below the next threshold", function()
    assert.equals("1.0 KB", bytes_util.format(1024))
  end)

  it("returns nil for nil input", function()
    assert.is_nil(bytes_util.format(nil))
  end)
end)
