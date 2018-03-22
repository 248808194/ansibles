main.yml下专门存放任务的
#添加模块需要重新编译nginx 带上原来的参数 + --add-module
    ./configure --prefix=/usr/local/nginx --with-http_lua_module --with-luajit-lib=/usr/local/luajit/lib/ --with-luajit-inc=/usr/local/luajit/include/luajit-2.0/ --with-ld-opt=-Wl,-rpath,/usr/local/luajit/lib --with-pcre=/usr/local/src/pcre-8.37 --user=www --group=www --with-poll_module --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --with-http_stub_status_module --with-file-aio --with-http_dav_module --with-http_realip_module --add-module=/tmp/ngx_http_redis-0.3.8
    make完之后在objs目录下就多了个nginx，这个就是新版本的程序了
    备份旧的nginx程序
    cp /usr/local/nginx/sbin/nginx/usr/local/nginx/sbin/nginx.bak
    把新的nginx程序覆盖旧的
    cp objs/nginx /usr/local/nginx/sbin/nginx


