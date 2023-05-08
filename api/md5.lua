
local resty_md5 = require "resty.md5"
    local md5 = resty_md5:new()
    if not md5 then
        txt = txt .. "failed to create md5 object"
    end

    local ok = md5:update("hel")
    if not ok then
        txt = txt .. "failed to add data"
    end

        -- md5:update() with an optional "len" parameter
    ok = md5:update("loxxx", 2)
    if not ok then
        txt = txt .."failed to add data"
    end

    local digest = md5:final()
    local str = require "resty.string"
    txt = txt .. "md5: " .. str.to_hex(digest)

