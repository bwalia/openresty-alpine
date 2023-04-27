#!/bin/bash

clear

docker cp nginx-dev.conf mynginx:/usr/local/openresty/nginx/conf/nginx.conf
docker cp response.lua mynginx:/usr/local/openresty/nginx/html/first.lua
docker cp openresty-admin/ mynginx:/usr/local/openresty/nginx/html/
docker exec -it mynginx openresty -t 
docker exec -it mynginx yarn build 
docker exec -it mynginx openresty -s reload