FROM nginx:1.19.1-alpine AS builder

# build Nginx module for HTTP SPNEGO auth

RUN apk add --no-cache build-base krb5-dev curl-dev pcre-dev zlib-dev krb5 git

RUN mkdir -p /usr/src && cd /usr/src && mkdir nginx \
 && curl -fSL https://nginx.org/download/nginx-1.19.1.tar.gz -o nginx.tar.gz \
 && tar -xzf nginx.tar.gz -C nginx --strip-components=1 \
 && cd /usr/src/nginx \
 && git clone https://github.com/stnoonan/spnego-http-auth-nginx-module.git \
 && ./configure --with-compat --add-dynamic-module=spnego-http-auth-nginx-module \
 && make modules

FROM nginx:1.19.1-alpine
RUN apk add --no-cache krb5
COPY --from=builder /usr/src/nginx/objs/ngx_http_auth_spnego_module.so /etc/nginx/modules/
