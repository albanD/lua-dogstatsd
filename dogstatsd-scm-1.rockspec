package = "dogstatsd"
version = "scm-1"

source = {
   url = "git://github.com/albanD/lua-dogstatsd"
}

description = {
   summary = "A dogstatsd client in lua",
   detailed = [[
   ]],
   homepage = "https://github.com/albanD/lua-dogstatsd",
   license = "GNU GPL"
}

dependencies = {
   "luasocket >= 2.0.2"
}

build = {
	type = "builtin",
	modules = {
		dogstatsd = "dogstatsd.lua"
	}
}
