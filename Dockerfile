ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}
COPY Dockerfile README.md /
# Install libmaxminddb0, geoipupdate and cron
RUN sed -r -i 's/^deb(.*)$/deb\1 contrib/g' /etc/apt/sources.list \
    && apt-get -y update \
    && apt-get --no-install-recommends -y install libmaxminddb0=1.5.2-1 geoipupdate=4.6.0-1+b3 cron=3.0pl1-137 libbrotli1=1.0.9-2+b2 \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

# Add modules, template GeoIP.conf, updater and cron scripts
COPY nginx/objs/ngx_*_module.so /usr/lib/nginx/modules/
RUN sed -i '1 i\include /etc/nginx/nginx_pre.conf;' /etc/nginx/nginx.conf
COPY GeoIP.conf.template /etc
COPY *.sh /docker-entrypoint.d/
