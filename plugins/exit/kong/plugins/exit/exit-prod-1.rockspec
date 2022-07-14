package = "exit"
version = "dev-1"
source = {
   url = "git+https://github.com/SuriyaRuk/exit-plugin-kong.git"
}
description = {
   homepage = "https://github.com/SuriyaRuk/exit-plugin-kong.git",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.exit.handler"] = "plugins/exit/kong/plugins/exit/handler.lua",
      ["kong.plugins.exit.schema"] = "plugins/exit/kong/plugins/exit/schema.lua",
   }
}
