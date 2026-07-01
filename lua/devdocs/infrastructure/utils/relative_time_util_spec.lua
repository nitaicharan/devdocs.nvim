local assert = require("luassert")

describe("relative_time_util", function()
  local relative_time
  local now

  before_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.infrastructure.utils.relative_time_util"] = nil
    relative_time = require("devdocs.infrastructure.utils.relative_time_util")

    -- fixed reference instant
    now = os.time({ year = 2026, month = 6, day = 30, hour = 12, min = 0, sec = 0 })
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.utils.relative_time_util"] = nil
  end)

  -- builds an ISO string for (now - seconds) in local time, suffixed +0000
  local function ago(reference, seconds)
    return os.date("%Y-%m-%dT%H:%M:%S+0000", reference - seconds)
  end

  it("returns 'just now' for deltas under a minute", function()
    assert.equals("just now", relative_time.format(ago(now, 5), now))
  end)

  it("formats minutes with pluralization", function()
    assert.equals("1 minute ago", relative_time.format(ago(now, 60), now))
    assert.equals("5 minutes ago", relative_time.format(ago(now, 5 * 60), now))
  end)

  it("formats hours with pluralization", function()
    assert.equals("1 hour ago", relative_time.format(ago(now, 3600), now))
    assert.equals("3 hours ago", relative_time.format(ago(now, 3 * 3600), now))
  end)

  it("formats days with pluralization", function()
    assert.equals("1 day ago", relative_time.format(ago(now, 86400), now))
    assert.equals("2 days ago", relative_time.format(ago(now, 2 * 86400), now))
  end)

  it("formats months", function()
    assert.equals("2 months ago", relative_time.format(ago(now, 60 * 86400), now))
  end)

  it("formats years", function()
    assert.equals("1 year ago", relative_time.format(ago(now, 400 * 86400), now))
  end)

  it("clamps future timestamps to 'just now'", function()
    assert.equals("just now", relative_time.format(ago(now, -120), now))
  end)

  it("formats the 360-364 day window as months, not '0 years ago'", function()
    assert.equals("12 months ago", relative_time.format(ago(now, 360 * 86400), now))
  end)

  it("from_epoch formats a past unix timestamp relative to now", function()
    assert.equals("2 days ago", relative_time.from_epoch(now - 2 * 86400, now))
  end)

  it("from_epoch clamps future timestamps to 'just now'", function()
    assert.equals("just now", relative_time.from_epoch(now + 120, now))
  end)

  it("from_epoch agrees with format for the same instant", function()
    local epoch = now - 5 * 3600
    local iso = os.date("%Y-%m-%dT%H:%M:%S+0000", epoch)
    assert.equals(relative_time.format(iso, now), relative_time.from_epoch(epoch, now))
  end)
end)
