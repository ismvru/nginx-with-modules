ARG NGINX_VERSION

FROM nginx:${NGINX_VERSION} as builder
WORKDIR /code
RUN apt-get -y update && apt-get -y install build-essential git wget libpcre2-dev libmaxminddb-dev zlib1g-dev libbrotli-dev
RUN git clone https://github.com/leev/ngx_http_geoip2_module.git \
    && git clone https://github.com/google/ngx_brotli.git \
    WORKDIR nginx
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
    && tar xf "nginx-${NGINX_VERSION}.tar.gz" -C "." --strip-components=1 \
    && ./configure --with-compat --add-dynamic-module=../ngx_http_geoip2_module --with-stream --add-dynamic-module=../ngx_brotli \
    && make modules

FROM nginx:${NGINX_VERSION}
COPY Dockerfile README.md /
# Install libmaxminddb0, geoipupdate and cron
RUN sed -r -i 's/^deb(.*)$/deb\1 contrib/g' /etc/apt/sources.list \
    && apt-get -y update \
    && apt-get --no-install-recommends -y install libmaxminddb0 geoipupdate cron libbrotli1 \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

# Add modules, template GeoIP.conf, updater and cron scripts
COPY --from=builder /code/nginx/objs/ngx_*_module.so /usr/lib/nginx/modules/
RUN sed -i '1 i\include /etc/nginx/nginx_pre.conf;' /etc/nginx/nginx.conf
COPY GeoIP.conf.template /etc
COPY *.sh /docker-entrypoint.d/
