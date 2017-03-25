#!/bin/bash
# 1 - Define Config
CURRDIR='/Users/laozhang/proxy'
SERVERLIST='23.106.132.195,47.90.42.37,47.91.143.225'
SSH_PKEY=/Users/laozhang/.ssh/id_rsa.nopwd
USERNAME=root
PROXY_PORT=18000
NGINX_BIN=/Users/laozhang/openresty/nginx/sbin/nginx
NGINX_CONF=$CURRDIR/proxy.conf
LOCALIP='127.0.0.1'
LOCALSERVERIP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
wdproxy="PROXY 10.199.75.12:8080; DIRECT;"
gwproxy="SOCKS5 $LOCALSERVERIP:$PROXY_PORT;DIRECT;"

# 2 - check env
`2>&1 $NGINX_BIN -V|tr ' '  '\n'|grep 'with-stream' &> /dev/null`
if [ $? -eq 1 ]; then
    echo "the $NGINX_BIN not install stream module,please install"
    exit
fi
#3 - create ssh prot
for ip in ${SERVERLIST//,/ } ; do
    m=$((j++))
    for (( n = 0; n < 5; n++ )); do
        port=170$m$n
        `nc -z $LOCALIP $port`
        if [ $? -ne 0 ]; then
            `ssh -D $port -Nf $USERNAME@$ip -i $SSH_PKEY > /dev/null 2>&1 & `
        fi
    done
done

# 4 - create nginx stream conf
string=""
for port in `ps axu|grep "ssh -D"|grep -v grep|grep -v $PROXY_PORT|awk -F'-D' '{print $2}'|cut -d " " -f 2|sort -n`
do
    string="server $LOCALIP:$port;
                ${string}"
done
cat>$NGINX_CONF<<NGINX_CONF
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    server {
        listen $PROXY_PORT;
        location /proxy.pac {
            default_type text/plain;
            charset  utf-8;
            root $CURRDIR;
            index proxy.pac;
        }
    }
}
stream {
    upstream proxy_cluster {
                $string
    }
    server {
                listen $PROXY_PORT;
                proxy_pass proxy_cluster;
                proxy_connect_timeout 1s;
                proxy_timeout 3s;
    }
}
NGINX_CONF

# 5 - create pac file 
if [ ! -f "$CURRDIR/proxy.pac" ]; then  
    touch $CURRDIR/proxy.pac;
fi
`cat $CURRDIR/proxy.txt| sed -e "s/{gwproxy}/$gwproxy/g"|sed -e "s/{wdproxy}/$wdproxy/g"> $CURRDIR/proxy.pac`

# 6 - reload or start nginx
`ps aux|grep -v grep|grep "$NGINX_BIN" &>/dev/null`
if [ $? -eq 1 ]; then
    `sudo $NGINX_BIN -c $NGINX_CONF`
    echo "$NGINX_BIN start succ"
else
    `sudo $NGINX_BIN -c $NGINX_CONF -s reload`
    echo "$NGINX_BIN reload succ"
fi