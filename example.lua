local dogstatsd = require "dogstatsd"

-- New default reporter
local reporter = dogstatsd.new()

reporter:gauge("testgauge", 123, "besttagever")

reporter:open_buffer(100)
reporter:gauge("testgauge", 125)
reporter:gauge("testgauge", 126)
reporter:gauge("testgauge", 127)
reporter:close_buffer()

reporter:gauge("testgauge", 123, "rate", 0.5)
reporter:gauge("testgauge", 123, "rate", 0.5)
reporter:gauge("testgauge", 123, "rate", 0.5)
