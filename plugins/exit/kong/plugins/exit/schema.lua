local typedefs = require "kong.db.schema.typedefs"

return {
  name = "exit",
  fields = {
    {
      -- this plugin will only be applied to Services or Routes
      consumer = typedefs.no_consumer
    },
    {
      -- this plugin will only run within Nginx HTTP module
      protocols = typedefs.protocols_http
    },
    {
      config = {
        type = "record",
        fields = {
          -- Describe your plugin's configuration's schema here.        
        {
          hide_brand = {
            type = "boolean",
            default = true,
          },
        },
        {
         status_502_to_504 = {
            type = "boolean",
            default = true,
          },
        },
      },
    },
  },
},
}
