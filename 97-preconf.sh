#!/bin/bash
set -e
SCRIPT_PATH=$(readlink -f "$0")
echo "Nginx module enabler ${SCRIPT_PATH}"

# Exit if we can't find needed variables
if [[ -n "${USE_GEOIP}" ]]; then
    echo 'load_module modules/ngx_http_geoip2_module.so;' >> /etc/nginx/nginx_pre.conf
    echo "Added ngx_http_geoip2_module to /etc/nginx/nginx_pre.conf"
fi

if [[ -n "${USE_GEOIP_STREAM}" ]]; then
    echo 'load_module modules/ngx_stream_geoip2_module.so;' >> /etc/nginx/nginx_pre.conf
    echo "Added ngx_stream_geoip2_module to /etc/nginx/nginx_pre.conf"
fi

if [[ -n "${USE_BROTLI_FILTER}" ]]; then
    echo 'load_module modules/ngx_http_brotli_filter_module.so;' >> /etc/nginx/nginx_pre.conf
    echo "Added ngx_http_brotli_filter_module to /etc/nginx/nginx_pre.conf"
fi

if [[ -n "${USE_BROTLI_STATIC}" ]]; then
    echo 'load_module modules/ngx_http_brotli_static_module.so;' >> /etc/nginx/nginx_pre.conf
    echo "Added ngx_http_brotli_static_module to /etc/nginx/nginx_pre.conf"
fi
