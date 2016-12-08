# lua-dogstatsd

Lua implementation of [datadog's python dogstatsd interface](http://datadogpy.readthedocs.io/en/latest/).

### Difference

* `dogstatsd.new` method that replaces the `initialize`.
* Use of default route from `/proc/net/route` for Linux is not implemented.
* `event` reporting is not implemented.