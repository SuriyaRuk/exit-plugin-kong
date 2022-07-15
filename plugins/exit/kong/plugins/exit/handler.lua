local ExitHandler = {
  VERSION  = "1.0.0",
  PRIORITY = 14,
}

function ExitHandler:header_filter(config)
    local kong = kong
    local status = kong.response.get_status()
    local status_upstream = kong.service.response.get_status()
 if status >= 400 and config.hide_brand and status ~=502 and status_upstream == nil then    
    local type = type
    local find = string.find
    local fmt  = string.format


    local CONTENT_TYPE    = "Content-Type"
    local ACCEPT          = "Accept"


    local TYPE_JSON       = "application/json"
    local TYPE_GRPC       = "application/grpc"
    local TYPE_HTML       = "text/html"
    local TYPE_XML        = "application/xml"


    local HEADERS_JSON = {
    [CONTENT_TYPE] = "application/json; charset=utf-8"
    }

    local HEADERS_HTML = {
    [CONTENT_TYPE] = "text/html; charset=utf-8"
    }

    local HEADERS_XML = {
    [CONTENT_TYPE] = "application/xml; charset=utf-8"
    }   

    local HEADERS_PLAIN = {
        [CONTENT_TYPE] = "text/plain; charset=utf-8"
    }


    local JSON_TEMPLATE = [[
    {
    "message": "%s"
    }
    ]]


    local HTML_TEMPLATE = [[
    <!doctype html>
    <html>
        <head>
            <meta charset="utf-8">
            <title>Error</title>
        </head>
    <body>
        <h1>Error</h1>
    <p>%s.</p>
    </body>
    </html>
    ]]

    local HTML_TEMPLATE_401 = [[
    <!doctype html>
    <html>
        <head>
            <meta charset="utf-8">
            <title>Unauthorized</title>
        </head>
    <body>
        <h1>%s.</h1>
    <p></p>
    </body>
    </html>
    ]]

    local XML_TEMPLATE = [[
    <?xml version="1.0" encoding="UTF-8"?>
    <error>
        <message>%s</message>
    </error>
    ]]


    local PLAIN_TEMPLATE = "%s\n"


    local BODIES = {
    s400 = "Bad request (400)",
    s401 = "Unauthorized (401)",
    s404 = "Not found (404)",
    s408 = "Request timeout (408)",
    s411 = "Length required (411)",
    s412 = "Precondition failed (412)",
    s413 = "Payload too large (413)",
    s414 = "URI too long (414)",
    s417 = "Expectation failed (417)",
    s494 = "Request header or cookie too large (494)",
    s500 = "An unexpected error occurred (500)",
    s502 = "An invalid response was received from the upstream server (502)",
    s503 = "The upstream server is currently unavailable (503)",
    s504 = "The upstream server is timing out (504)",
    default = "The upstream server responded with %d"
    }

    local accept_header = kong.request.get_header(ACCEPT)
    if type(accept_header) == "table" then
    accept_header = accept_header[1]
    end

    if accept_header == nil then
        accept_header = kong.request.get_header(CONTENT_TYPE)
        if type(accept_header) == "table" then
            accept_header = accept_header[1]
        end
    end

    if accept_header == nil then
        accept_header = kong.configuration.error_default_type
    end

    local message = BODIES["s" .. status] or fmt(BODIES.default, status)

    local headers
    if find(accept_header, TYPE_JSON, nil, true) == 1 then
        message = fmt(JSON_TEMPLATE, message)
        headers = HEADERS_JSON

    elseif find(accept_header, TYPE_GRPC, nil, true) == 1 then
        message = { message = message }

    elseif find(accept_header, TYPE_HTML, nil, true) == 1 and status == 401 then
        message = fmt(HTML_TEMPLATE_401, message)
        headers = HEADERS_HTML

    elseif find(accept_header, TYPE_HTML, nil, true) == 1 then
        message = fmt(HTML_TEMPLATE, message)
        headers = HEADERS_HTML

    elseif find(accept_header, TYPE_XML, nil, true) == 1 then
        message = fmt(XML_TEMPLATE, message)
        headers = HEADERS_XML

    else
        message = fmt(PLAIN_TEMPLATE, message)
        headers = HEADERS_PLAIN
    end

    -- Reset relevant context values
     kong.ctx.core.buffered_proxying = nil
    kong.ctx.core.response_body = nil

    if ctx then
        ctx.delay_response = nil
        ctx.delayed_response = nil
        ctx.delayed_response_callback = nil
    end

    kong.response.exit(status, message, headers)

 end

    if config.status_502_to_504 and status == 502 and status_upstream ~= 502 then
        kong.response.exit(504,"The upstream server is timing out")  
    end

end

return ExitHandler
