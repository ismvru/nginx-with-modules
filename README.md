# Nginx with GeoIP2 and Brotli modules in docker
<!-- markdownlint-disable line-length -->
[![Docker Image CI](https://github.com/ismvru/nginx-with-modules/actions/workflows/docker-image.yml/badge.svg)](https://github.com/ismvru/nginx-with-modules/actions/workflows/docker-image.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/ismv/nginx-with-modules)

- [Nginx with GeoIP2 and Brotli modules in docker](#nginx-with-geoip2-and-brotli-modules-in-docker)
  - [Usage](#usage)
    - [Start](#start)
    - [Env variables](#env-variables)
    - [Example `.env` file](#example-env-file)
    - [Own container](#own-container)
  - [Example Nginx configs](#example-nginx-configs)
    - [Nginx HTTP config with GeoIP](#nginx-http-config-with-geoip)
    - [Nginx stream config with GeoIP](#nginx-stream-config-with-geoip)
    - [Nginx brotli compression](#nginx-brotli-compression)
  - [Build](#build)
  - [Scripts](#scripts)
    - [97-preconf.sh](#97-preconfsh)
    - [98-geoip-updater.sh](#98-geoip-updatersh)
    - [99-cron.sh](#99-cronsh)

Nginx with [ngx_http_geoip2](https://github.com/leev/ngx_http_geoip2_module) and [ngx_brotli](https://github.com/google/ngx_brotli) modules

See [ngx_http_geoip2 module documentation](https://docs.nginx.com/nginx/admin-guide/dynamic-modules/geoip2/) and [ngx_brotli module documentation](https://docs.nginx.com/nginx/admin-guide/dynamic-modules/brotli/) for configuration docs.

## Usage

### Start

- Providing variables in run command

```bash
docker run -d \
-v $PWD/nginx_conf:/etc/nginx/conf.d/ \
-v $PWD/GeoIP:/var/lib/GeoIP/ \
-e USE_GEOIP=true \
-e USE_GEOIP_STREAM=true \
-e USE_BROTLI_FILTER=true \
-e USE_BROTLI_STATIC=true \
-e MM_USE_UPDATER=true \
-e MM_ACCOUNT_ID=123456 \
-e MM_LICENSE_KEY=BlahBlahBlah \
-e MM_EDITIONS="GeoLite2-ASN GeoLite2-City GeoLite2-Country" \
-e MM_CRON="0 0 * * *" \
-p 80:80 \
image:tag
```

- `.env` file

```bash
docker run -d \
-v $PWD/nginx_conf:/etc/nginx/conf.d/ \
-v $PWD/GeoIP:/var/lib/GeoIP/ \
--env-file .env \
-p 80:80 \
image:tag
```

### Env variables

| Variable            | Description                                                                                 | Script                              | Example                      |
| ------------------- | ------------------------------------------------------------------------------------------- | ----------------------------------- | ---------------------------- |
| `USE_GEOIP`         | Enable ngx_http_geoip2_module in `/etc/nginx/nginx.conf`                                    | `97-preconf.sh`                     | `true`                       |
| `USE_GEOIP_STREAM`  | Enable ngx_stream_geoip2_module in `/etc/nginx/nginx.conf`                                  | `97-preconf.sh`                     | `true`                       |
| `USE_BROTLI_FILTER` | Enable ngx_http_brotli_filter_module in `/etc/nginx/nginx.conf`                             | `97-preconf.sh`                     | `true`                       |
| `USE_BROTLI_STATIC` | Enable ngx_http_brotli_static_module in `/etc/nginx/nginx.conf`                             | `97-preconf.sh`                     | `true`                       |
| `MM_USE_UPDATER`    | You need to set this variable if you want to use official updater                           | `98-geoip-updater.sh`, `99-cron.sh` | `true`                       |
| `MM_ACCOUNT_ID`     | maxmind.com Account ID. If not provided - Updater will not work.                            | `98-geoip-updater.sh`               | `123456`                     |
| `MM_LICENSE_KEY`    | maxmind.com License key. If not provided - Updater will not work.                           | `98-geoip-updater.sh`               | `BlahBlahBlah`               |
| `MM_EDITIONS`       | maxmind.com databases. If not provided - Updater will not work.                             | `98-geoip-updater.sh`               | `GeoLite2-City GeoLite2-ASN` |
| `MM_CRON`           | Crontab entry, when we will try to update databases. If not provided - Cron will not start. | `99-cron.sh`                        | `46 15 * * 6,4`              |

### Example `.env` file

```text
USE_GEOIP=true
USE_GEOIP_STREAM=true
USE_BROTLI_FILTER=true
USE_BROTLI_STATIC=true
MM_USE_UPDATER=true
MM_ACCOUNT_ID=123456
MM_LICENSE_KEY=BlahBlahBlah
MM_EDITIONS=GeoLite2-ASN GeoLite2-City GeoLite2-Country
MM_CRON=46 15 * * 6,4
```

### Own container

```dockerfile
FROM image:tag
COPY static-html-directory /usr/share/nginx/html
COPY configs/*.conf /etc/nginx/conf.d/
```

## Example Nginx configs

See [examples](examples/)

### Nginx HTTP config with GeoIP

Example: [examples/nginx_http.conf](examples/nginx_http.conf)

`http` block in `/etc/nginx/nginx.conf`

```nginx
http {
  geoip2 /var/lib/GeoIP/GeoLite2-Country.mmdb {
    $geoip2_data_country_iso_code country iso_code;
  }

  map $geoip2_data_country_iso_code $allowed_country {
    default no;
    FR yes; # France
    BE yes; # Belgium
    DE yes; # Germany
    CH yes; # Switzerland
  }

  server {
    # Block forbidden country
    if ($allowed_country = no) {
    return 418;
    }
    # Any other server config here
  }
}
```

### Nginx stream config with GeoIP

`stream` block in `/etc/nginx/nginx.conf`

```nginx
stream {
  geoip2 /var/lib/GeoIP/GeoLite2-Country.mmdb {
      $geoip2_data_continent_code continent code;
  }

  upstream all {
      server all1.example.com:12345;
      server all2.example.com:12345;
  }

  upstream eu {
      server eu1.example.com:12345;
      server eu2.example.com:12345;
  }

  upstream na {
      server na1.example.com:12345;
      server na2.example.com:12345;
  }

  map $geoip2_data_continent_code $nearest_server {
      default all;
      EU      eu;
      NA      na;
  }
  server {
    listen 12345;
    proxy_pass $nearest_server;
   }
}
```

### Nginx brotli compression

`http`, `server`, or `location` blocks in Nginx configuration

```nginx
http {
  brotli on;
  brotli_comp_level 6;
  brotli_static on;
  brotli_types application/atom+xml application/javascript application/json application/rss+xml
              application/vnd.ms-fontobject application/x-font-opentype application/x-font-truetype
              application/x-font-ttf application/x-javascript application/xhtml+xml application/xml
              font/eot font/opentype font/otf font/truetype image/svg+xml image/vnd.microsoft.icon
              image/x-icon image/x-win-bitmap text/css text/javascript text/plain text/xml;
  server {
    # Any other server config here
  }
}
```

## Build

```bash
# Install build reqs
apt-get -y update && apt-get -y install build-essential git wget libpcre2-dev libmaxminddb-dev zlib1g-dev libbrotli-dev
# Clone module geoip2 git repo
git clone https://github.com/leev/ngx_http_geoip2_module.git
# Clone module brotil git repo
git clone https://github.com/google/ngx_brotli.git
# Make temp dir for nginx modules building
mkdir -p nginx
# Download and unpack nginx sources
wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
tar xf "nginx-${NGINX_VERSION}.tar.gz" -C "nginx" --strip-components=1
# Go to nginx sources dir and compile modules
cd nginx
./configure --with-compat --add-dynamic-module=../ngx_http_geoip2_module --with-stream --add-dynamic-module=../ngx_brotli
make modules
cd ..

# Finally build docker image
docker build . -t image:tag --build-arg NGINX_VERSION=${NGINX_VERSION}
```

## Scripts

### 97-preconf.sh

Script for dynamic enable modules in Nginx.conf

### 98-geoip-updater.sh

Script for configure GeoIP2 updater and update databases

### 99-cron.sh

Script, cunning cron for GeoIP2 databases update
