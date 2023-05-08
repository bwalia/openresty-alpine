-- handle nginx.json file
-- parse nginx.json file
-- transform nginx.json to nginx.conf 
-- compare md5 hash of nginx.conf in memory with file on disc
-- if hash are the same return api the file already then message
-- if uuid or nginx.conf hash are different save new file in the destination path
-- if uuid already exist archive first existing file and save updated new configuration

-- local content = 'a'
-- local md5HashContent = md5(content)
-- content = "b"
-- if md5()
local cjson = require("cjson")
-- local md5 = require("md5.lua")
local _Response = {}
txt = ''
depth = 0

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

function sorting_fun(json_obj,k,space)
    for i = 1, tablelength(json_obj) do
        local objj = "lua_red_"..tostring(i)
        if json_obj[objj]~= nil then
            if space==true then depth = depth + 1 end
            nested_fun(json_obj[objj],k,space) 
            if space==true then depth = depth - 1 end
        else 
            depth = depth + 1
            nested_fun(json_obj,k,space) 
            depth = depth - 1
            break 
        end
    end
end

function log_format(arr)
    txt = txt .. "   log_format "
    for k, v in pairs(arr) do 
        txt = txt .. "    " .. tostring(v) .. "\n"
    end
end

function nested_fun(json_obj,nval,space)
    -- local mytxt = ""
    -- string.rep("A", 200)
    for k,v in next,json_obj do 
        if type(k) == "number" then k = "" end       
        if nval == "server" then k = "server " end       
        if type(v) == 'table' then
            if k == 'upstream big_server_com' and nval == 'http' then txt = txt .. "  " end             
            
            if k ~= 'include' and k ~= 'server' and k ~= 'log_format' then 
                txt = txt .. string.rep(" ",depth)
                txt = txt ..k .. " { \n" 
            end


            if k == 'log_format' then log_format(v,k) elseif tablelength(v)>1 then 
                sorting_fun(v,k,true)           
            else
                depth = depth + 1
                nested_fun(v,k,true) 
                depth = depth - 1
            end

            if k == 'upstream big_server_com' and nval == 'http' then txt = txt .. "  " end             


            if k ~= 'include' and k ~= 'server' and k ~= 'log_format' then 
                txt = txt .. string.rep(" ",depth)
                txt = txt .. "}\n" 
            end

        else
            if nval == 'http' then txt = txt .. "  " end
            if nval == 'upstream big_server_com' then txt = txt .. "  " end             

            if k ~= 'include' and k ~= 'server' and k ~= 'log_format' and space == true then 
                txt = txt .. string.rep(" ",depth) .. k .. " " .. tostring(v) ..";\n"
            else
                txt = txt .. k .. " " .. tostring(v) ..";\n"
            end
        end
    end
    -- return mytxt
end
function _Response.CreateConf()
    local json_str
    local file, err = io.open("/usr/local/openresty/nginx/html/data/nginx.json")
    if file == nil then
        local data = {
            error = err,
            message = "data not found!!",
            status = false
        }
        -- Encode the table as a JSON string
        json_str = cjson.encode(data)
    else
        local jsonString = file:read "*a"
        file:close()
        local wfile, werr = io.open("/usr/local/openresty/nginx/nginx_my.conf", "w")
        if wfile == nil then
            local data = {
                error = werr,
                message = "file not written!!",
                status = false
            }
            -- Encode the table as a JSON string
            json_str = cjson.encode(data)
        else
            local t = cjson.decode(tostring(jsonString))
            sorting_fun(t,'',false)
            wfile:write(txt)
            wfile:close()
            local data = {
                data = t,
                message = "File created successfully!!",
                status = true
            }
            -- Encode the table as a JSON string
            json_str = cjson.encode(data)
            -- Return the JSON string
        end
        
    end
    return json_str
end

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
 end

function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
 end

return _Response