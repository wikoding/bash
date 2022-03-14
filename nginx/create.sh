#/bin/bash
#author: wikoding.com

arg_domain=""
arg_pass=""
arg_tls="false"
arg_cert=""
arg_cert_key=""

while [[ $# -gt 0 ]]
do
    case $1 in
        --domain|-d)
            arg_domain="$2"
            shift 2
            ;;
        --pass|-p)
            arg_pass="$2"
            shift 2
            ;;
        --tls)
            arg_tls="true"
            shift
            ;;
        --cert)
            arg_pass="$2"
            shift 2
            ;;
        --cert-key)
            arg_pass="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [ -z $arg_domain ]; then
    output_error "No domain specified by --domain or -d"
    exit 1
fi

if [ -z $arg_pass ]; then
    output_error "No pass specified by --pass or -p"
    exit 1
fi

if [ $arg_tls = "true" ]; then
    if [ -z $arg_cert ]; then
        $arg_cert="ssl/$arg_domain/cert.pem"
    fi

    if [ -z $arg_cert_key ]; then
        $arg_cert_key="ssl/$arg_domain/key.pem"
    fi
fi

echo "  domain: $arg_domain"
echo "    pass: $arg_pass"
echo "     tls: $arg_tls"
echo "    cert: $arg_cert"
echo "cert key: $arg_cert_key"

echo "=========================写入nginx配置文件 开始========================="
nginx_config_file="/etc/nginx/sites-available/$arg_domain"
nginx_config_link="/etc/nginx/sites-enabled/$arg_domain"
echo "nginx config file: $nginx_config_file"
echo "nginx config link: $nginx_config_link"

if [ $arg_tls = "true" ]
then
cat >"$nginx_config_file" <<EOF
server {
    listen        80;
    server_name   $arg_domain;
    return 301    https://\$host\$request_uri;
}

server {
    listen                 443 ssl http2;
    listen                 [::]:443;
    server_name            $arg_domain;
    client_max_body_size   0;
    ssl_certificate        $arg_cert;
    ssl_certificate_key    $arg_cert_key;
    location / {
        proxy_pass         $arg_pass;
        proxy_http_version 1.1;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header   Host \$host;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF
else
cat >"$nginx_config_file" <<EOF
server {
    listen        80;
    server_name   $arg_domain;
    client_max_body_size   0;
    location / {
        proxy_pass         $arg_pass;
        proxy_http_version 1.1;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header   Host \$host;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF
fi

systemctl restart nginx

echo "=========================写入nginx配置文件 结束========================="