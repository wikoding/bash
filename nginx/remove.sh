#/bin/bash
#author: wikoding.com

arg_domain=""

while [[ $# -gt 0 ]]
do
    case $1 in
        --domain|-d)
            arg_domain="$2"
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

echo "  domain: $arg_domain"

echo "=========================移除nginx配置文件 开始========================="
nginx_config_file="/etc/nginx/sites-available/$arg_domain"
nginx_config_link="/etc/nginx/sites-enabled/$arg_domain"
echo "nginx config file: $nginx_config_file"
echo "nginx config link: $nginx_config_link"

rm "$nginx_config_file"
rm "$nginx_config_link"
systemctl restart nginx

echo "=========================移除nginx配置文件 结束========================="