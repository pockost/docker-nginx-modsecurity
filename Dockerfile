# First stage build container
# Build libmodsecurity and nginx plugin
FROM alpine:3.8

LABEL maintainer="Romain THERRAT <romain@pockost.com>"

RUN set -xe \
  && BUILD_TOOLS="git libtool automake autoconf g++ curl-dev libxml2-dev linux-headers pcre-dev make yajl-dev geoip-dev" \
	&& apk add --no-cache --virtual .build-deps \
     $BUILD_TOOLS \
     flex \
     bison \
  && git clone https://github.com/SpiderLabs/ModSecurity /usr/local/src/libmodsecurity \
  && cd /usr/local/src/libmodsecurity \
  && git checkout v3/master \
  && sh build.sh \
  && git submodule init \
  && git submodule update \
  && ./configure --with-yajl=/usr/ \
  && make \
  && make install \
  && apk del $BUILD_TOOLS

ENV NGINX_VERSION 1.15.2

RUN set -xe \
  && git clone https://github.com/SpiderLabs/ModSecurity-nginx /usr/local/src/libmodsecurity-nginx

RUN cd /usr/local/src/ \
  && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar xf nginx-${NGINX_VERSION}.tar.gz \
  && rm nginx-${NGINX_VERSION}.tar.gz

RUN cd /usr/local/src/nginx-${NGINX_VERSION} \
  && ./configure --with-compat --add-dynamic-module=/usr/local/src/libmodsecurity-nginx/ \
  && make modules

# Second stage building container
# Retreive libmodsecurity.so and install compiled dependencies
FROM nginx:1.15.2-alpine

LABEL maintainer="Romain THERRAT <romain@pockost.com>"

COPY --from=0 /usr/local/src/nginx-${NGINX_VERSION}/objs/ngx_http_modsecurity_module.so /etc/nginx/modules
COPY --from=0 /usr/local/modsecurity/lib/libmodsecurity.so /usr/local/lib/libmodsecurity.so

RUN  apk add --no-cache libcurl yajl libstdc++ \
  && ln -s /usr/local/lib/libmodsecurity.so /usr/local/lib/libmodsecurity.so.3 \
  && sed -i '/events {/i \
       load_module modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
