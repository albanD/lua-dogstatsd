local luasocket = require "socket"
local math = require "math"

local dogstatsd = {}
-- Make it look like a class
dogstatsd.__index = dogstatsd

-- Internal functions

local get_socket = function(self)
  if not self.socket then
    self.socket = luasocket.udp()
    self.socket:setpeername(self.host, self.port)
  end
  return self.socket
end

local close_socket = function(self)
  if self.socket then
    self.socket:close()
    self.socket = nil
  end
end

local server_send = function(self, data)
  local socket = get_socket(self)
  socket:send(data)
end

local flush_buffer = function(self)
  server_send(self, self.buffer)
  self.buffer = ""
end

local buffer_send = function(self, data)
  self.buffer = self.buffer .. "\n" .. data
  if #self.buffer > self.max_buffer_size then
    flush_buffer(self)
  end
end

local report = function(self, metric, metric_type, value, tags, sample_rate)
  -- arg checking
  if type(tags) == "string" then
    tags = {tags}
  end

  if not value then return end

  if sample_rate ~= 1 and math.random() > sample_rate then
    return
  end

  local payload = {}

  if self.constant_tags then
    if tags then
      table.insert(tags, constant_tags)
    else
      tags = {constant_tags}
    end
  end

  if self.namespace then
    table.insert(payload, self.namespace)
    table.insert(payload, ".")
  end
  table.insert(payload, metric)
  table.insert(payload, ":")
  table.insert(payload, value)
  table.insert(payload, "|")
  table.insert(payload, metric_type)

  if sample_rate ~= 1 then
    table.insert(payload, "|@")
    table.insert(payload, sample_rate)
  end

  if tags then
    table.insert(payload, "|#" .. table.concat(tags, ","))
  end

  payload = table.concat(payload, "")

  self:send(payload)
end

-- Public interface

function dogstatsd:open_buffer(max_buffer_size)
  max_buffer_size = max_buffer_size or self.max_buffer_size
  self.buffer = ""
  self.send = buffer_send
end

function dogstatsd:close_buffer()
  self.send = server_send
  flush_buffer(self)
end

function dogstatsd:gauge(metric, value, tags, sample_rate)
  sample_rate = sample_rate or 1
  return report(self, metric, 'g', value, tags, sample_rate)
end

function dogstatsd:increment(metric, value, tags, sample_rate)
  sample_rate = sample_rate or 1
  value = value or 1
  return report(self, metric, 'c', value, tags, sample_rate)
end

function dogstatsd:decrement(metric, value, tags, sample_rate)
  sample_rate = sample_rate or 1
  value = -value or -1
  return report(self, metric, 'c', value, tags, sample_rate)
end

function dogstatsd:histogram(metric, value, tags, sample_rate)
  sample_rate = sample_rate or 1
  return report(self, metric, 'h', value, tags, sample_rate)
end

function dogstatsd:timing(metric, value, tags, sample_rate)
  sample_rate = sample_rate or 1
  return report(self, metric, 'ms', value, tags, sample_rate)
end

function dogstatsd:set(metric, value, tags, sample_rate)
  sample_rate = sample_rate or 1
  return report(self, metric, 's', value, tags, sample_rate)
end

function dogstatsd:event()
  error("event reporting not implemented")
end

  
-- Creation method

dogstatsd.new = function(host, port,
        max_buffer_size,
        namespace, constant_tags,
        use_ms, use_default_route)
  -- Default options values
  host = host or "localhost"
  port = port or 8125
  max_buffer_size = max_buffer_size or 50
  use_default_route = use_default_route or false

  -- Not supported options (yet)
  if use_default_route then
    error "use_default_route is not supported"
  end

  -- Create new instance
  local new = {
    buffer = "",
    send = server_send,
    host = host,
    port = port,
    max_buffer_size = max_buffer_size,
    use_ms = use_ms,
    use_default_route = use_default_route
  }
  setmetatable(new, dogstatsd)

  return new
end

return dogstatsd
