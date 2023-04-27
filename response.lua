local _M = {}
function _M.printReponse(k, v)
    ngx.header.content_type = "text/html"
    local html = [[
    <html>
    <head>
    <title>Hello, world!</title>
    </head>
    <body>
    <span>]] .. k .. [[: </span>
    <span> ]] .. v .. [[</span>
    <br><br><br>
    </body>
    </html>
    ]]
    ngx.say(html)
    -- comment
end

return _M
