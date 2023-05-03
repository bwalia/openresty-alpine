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
function nested_fun(json_obj,nval)
    -- local mytxt = ""
    for k, v in pairs(json_obj) do 
        if type(k) == "number" then k = "" end       
        if type(v) == 'table' then
            txt = txt .. " " ..k .. "{ \n"
            nested_fun(v,k)
            txt = txt .. "}\n"
        else
            if nval == 'http' then
                txt = txt .. "   " .. k .. " \"" .. tostring(v) .. "\";\n"
            elseif string.find(tostring(v), "\"") then
                txt = txt .. k .. " " .. v .. ";\n"
            else 
                txt = txt .. k .. " " .. tostring(v) .. ";\n"
            end
        end
    end
    -- return mytxt
end
function _Response.CreateConf()
    local json_str
    local file, err = io.open("/usr/local/openresty/nginx/html/data/nginx.json", "r")
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
        local wfile, werr = io.open("/usr/local/openresty/nginx/nginx_my.conf", "a+")
        if wfile == nil then
            local data = {
                error = werr,
                message = "file not written!!",
                status = false
            }
            -- Encode the table as a JSON string
            json_str = cjson.encode(data)
        else
            local t = cjson.decode(jsonString)
            nested_fun(t,'')
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