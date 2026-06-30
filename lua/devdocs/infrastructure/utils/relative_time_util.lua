local make_logged = require("devdocs.application.helpers.make_logged")

local function plural(n, unit)
  return string.format("%d %s%s ago", n, unit, n == 1 and "" or "s")
end

---@param delta integer seconds elapsed (clamped to >= 0)
---@return string
local function humanize(delta)
  if delta < 0 then
    delta = 0
  end

  if delta < 60 then
    return "just now"
  end

  local minutes = math.floor(delta / 60)
  if minutes < 60 then
    return plural(minutes, "minute")
  end

  local hours = math.floor(delta / 3600)
  if hours < 24 then
    return plural(hours, "hour")
  end

  local days = math.floor(delta / 86400)
  if days < 30 then
    return plural(days, "day")
  end

  local months = math.floor(days / 30)
  if months <= 12 then
    return plural(months, "month")
  end

  return plural(math.floor(months / 12), "year")
end

local M = {
  ---@param iso string ISO-8601 timestamp, e.g. "2026-04-13T00:45:51+0100"
  ---@param now? integer epoch seconds to compare against (defaults to os.time())
  ---@return string relative phrase, e.g. "2 months ago"
  format = function(iso, now)
    assert(type(iso) == "string", "iso param is required")

    local y, mo, d, h, mi, s = iso:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    assert(y ~= nil, "iso param must be an ISO-8601 timestamp")

    local epoch = os.time({
      year = tonumber(y),
      month = tonumber(mo),
      day = tonumber(d),
      hour = tonumber(h),
      min = tonumber(mi),
      sec = tonumber(s),
    })

    return humanize((now or os.time()) - epoch)
  end,
}

return make_logged("utils/relative_time_util", M)
