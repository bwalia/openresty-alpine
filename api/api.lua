function strSplit(delim, str)
    local t = {}

    for substr in string.gmatch(str, "[^" .. delim .. "]*") do
        if substr ~= nil and string.len(substr) > 0 then
            table.insert(t, substr)
        end
    end

    return t
end

function generate_uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
  end

-- Read body being passed
-- Required for ngx.req.get_body_data()
ngx.req.read_body();
-- Parser for sending JSON back to the client
local cjson = require("cjson")
-- Strip the api/ bit from the request path
local reqPath = ngx.var.uri:gsub("api/", "");
-- Get the request method (POST, GET etc..)
local reqMethod = ngx.var.request_method
-- Parse the body data as JSON
local body = ngx.req.get_body_data() ==
    -- This is like a ternary statement for Lua
    -- It is saying if doesn't exist at least
    -- define as empty object
    nil and {} or cjson.decode(ngx.req.get_body_data());

Api = {}
Api.__index = Api
-- Declare API not yet responded
Api.responded = false;
-- Function for checking input from client
function Api.endpoint(method, path, callback)
    do return callback(body) end
    -- If API not already responded
    if Api.responded == false then
        -- KeyData = params passed in path
        local keyData = {}
        -- If this endpoint has params
        if string.find(path, "<(.-)>")
        then
            -- Split origin and passed path sections
            local splitPath = strSplit("/", path)
            local splitReqPath = strSplit("/", reqPath)
            -- Iterate over splitPath
            for i, k in pairs(splitPath) do
                -- If chunk contains <something>
                if string.find(k, "<(.-)>")
                then
                    -- Add to keyData
                    keyData[string.match(k, "%<(%a+)%>")] = splitReqPath[i]
                    -- Replace matches with default for validation
                    reqPath = string.gsub(reqPath, splitReqPath[i], k)
                end
            end
        end

        -- return false if path doesn't match anything
        if reqPath ~= path
        then
            return false;
        end
        -- return error if method not allowed
        if reqMethod ~= method
        then
            return ngx.say(
                cjson.encode({
                    error = 500,
                    message = "Method " .. reqMethod .. " not allowed"
                })
            )
        end
        ngx.header['Access-Control-Allow-Origin'] = '*'
        ngx.header['Content-Type'] = 'application/json'

        -- Make sure we don't run this again
        Api.responded = true;

        -- return body if all OK
        body.keyData = keyData
        return callback(body);
    end

    return false;
end

Api.endpoint('POST', '/post-servers',
    function(body)
        local serverId = generate_uuid
        body.id = "0be611c11371424ea8b725107b4b0e11"
        local file = io.open("/usr/local/openresty/nginx/html/data/servers/0be611c11371424ea8b725107b4b0e11.json", "w")

        if file then
            -- Write the JSON data to the file
            file:write(cjson.encode(body))

            -- Close the file
            file:close()

            -- Return a success message
            ngx.say("File written successfully")
        else
            -- Return an error message
            ngx.say("Error opening file")
        end
    end
)

Api.endpoint('GET', '/servers',
    function(body)
        local files = {}
        -- Run the 'ls' command to get a list of filenames
        local output = io.popen("ls /usr/local/openresty/nginx/html/data/servers"):read("*all")
        for filename in string.gmatch(output, "[^\r\n]+") do
            table.insert(files, filename)
        end
        -- Print the list of filenames
        for _, filename in ipairs(files) do
            print(filename)
        end
        local jsonData = {}
        for _, filename in ipairs(files) do
            local file, err = io.open("/usr/local/openresty/nginx/html/data/servers/" .. filename, "rb")
            if file == nil then
                ngx.say("Couldn't read file: " .. err)
            else
                local jsonString = file:read "*a"
                file:close()
                local servers = cjson.decode(jsonString)

                jsonData[_] = servers
            end
        end
        return ngx.say(cjson.encode({ data = jsonData, total = 3 }))
    end
)
