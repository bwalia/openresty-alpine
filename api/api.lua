local cjson = require "cjson"

local function generate_uuid()
    local random = math.random(1000000000)                                            -- generate a random number
    local timestamp = os.time()                                                       -- get the current time in seconds since the Unix epoch
    local hash = ngx.md5(tostring(random) .. tostring(timestamp))                     -- create a hash of the random number and timestamp
    local uuid = string.format("%s-%s-%s-%s-%s", string.sub(hash, 1, 8), string.sub(hash, 9, 12),
        string.sub(hash, 13, 16), string.sub(hash, 17, 20), string.sub(hash, 21, 32)) -- format the hash as a UUID
    return uuid
end

local function is_uuid(str)
    local uuid_pattern = "^([0-9a-fA-F]-){4}[0-9a-fA-F]-([0-9a-fA-F]-){3}[0-9a-fA-F]$"
    return string.match(str, uuid_pattern) ~= nil
end

local function listServers()
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

local function createServer(body)
    local serverId = generate_uuid()
    local file, err = io.open("/usr/local/openresty/nginx/html/data/servers/" .. serverId .. ".json", "w")
    local keyset = {}
    local n = 0
    for k, v in pairs(body) do
        n = n + 1
        table.insert(keyset, cjson.decode(k))
    end
    local payloads = keyset[1]
    payloads.id = serverId
    if file then
        -- Write the JSON data to the file
        file:write(cjson.encode(payloads))
        -- Close the file
        file:close()
        return ngx.say(cjson.encode({ data = { id = serverId } }))
    else
        ngx.say("Error opening file", err)
    end
end

local function listServer(args, id)
    local file, err = io.open("/usr/local/openresty/nginx/html/data/servers/" .. id .. ".json", "rb")
    if file == nil then
        ngx.say("Couldn't read file: " .. err)
    else
        local jsonString = file:read "*a"
        file:close()
        local jsonData = cjson.decode(jsonString)
        ngx.say(cjson.encode({data = jsonData}))
    end
end

local function handle_get_request(args, path)
    -- handle GET request logic here
    local delimiter = "/"
    local subPath = {}
    for substring in string.gmatch(path, "[^" .. delimiter .. "]+") do
        table.insert(subPath, substring)
    end
    local pattern = ".*/(.*)"
    local uuid = string.match(path, pattern)

    if path == "servers" then
        listServers()
    elseif (#uuid == 36 or #uuid == 32) and subPath[1] == "servers" then
        listServer(args, uuid)
    end
end

local function handle_post_request(args, path)
    -- handle POST request logic here
    if path == "servers" then
        createServer(args)
    end
end

-- Function to handle PUT requests
local function handle_put_request(args, path)
    -- handle PUT request logic here
    ngx.say(cjson.encode(args), path)
    local response_data = { message = "Hello, PUT request!" }
    ngx.say(cjson.encode(response_data))
end

-- Function to handle DELETE requests
local function handle_delete_request(args, path)
    -- handle DELETE request logic here
    local response_data = { message = "Hello, DELETE request!" }
    ngx.say(cjson.encode(response_data))
end

-- Get the path name from the URI
local path_name = ngx.var.uri:match("^/api/(.*)$")

-- Determine the request method and call the appropriate function
if ngx.req.get_method() == "GET" then
    handle_get_request(ngx.req.get_uri_args(), path_name)
elseif ngx.req.get_method() == "POST" then
    ngx.req.read_body()
    handle_post_request(ngx.req.get_post_args(), path_name)
elseif ngx.req.get_method() == "PUT" then
    ngx.req.read_body()
    handle_put_request(ngx.req.get_post_args(), path_name)
elseif ngx.req.get_method() == "DELETE" then
    ngx.req.read_body()
    handle_delete_request(ngx.req.get_post_args(), path_name)
else
    ngx.exit(ngx.HTTP_NOT_ALLOWED)
end
