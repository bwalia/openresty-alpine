#!/bin/bash

clear

docker cp nginx-dev.conf ebee7ff5386d:/usr/local/openresty/nginx/conf/nginx.conf
docker cp response.lua ebee7ff5386d:/usr/local/openresty/nginx/html/first.lua
docker cp api/ ebee7ff5386d:/usr/local/openresty/nginx/html/
docker cp data/ ebee7ff5386d:/usr/local/openresty/nginx/html/
docker cp openresty-admin/src ebee7ff5386d:/usr/local/openresty/nginx/html/openresty-admin/
docker exec -it ebee7ff5386d openresty -t 
docker exec -it ebee7ff5386d openresty -s reload