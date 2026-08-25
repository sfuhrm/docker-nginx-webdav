FROM alpine:latest

LABEL maintainer="sfuhrm"

EXPOSE 8080/tcp

RUN apk add --no-cache nginx nginx-mod-http-dav-ext openssl && \
    mkdir -p "/media/data" \
             "/var/lib/nginx/tmp/client_body" \
             "/var/lib/nginx/tmp/proxy" \
             "/var/lib/nginx/tmp/fastcgi" \
             "/var/lib/nginx/tmp/uwsgi" \
             "/var/lib/nginx/tmp/scgi" && \
    chown -R nginx:nginx "/media/data" "/var/lib/nginx" && \
    chown nginx:nginx "/etc/nginx/http.d/default.conf" && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    rm -rf /usr/share/nginx/html /var/lib/nginx/html /var/cache/apk/* /tmp/* /var/tmp/* && \
    find / -xdev -type f -perm /6000 -exec chmod a-s {} +

COPY --chmod=0555 entrypoint.sh /
COPY --chown=root:root webdav.conf /etc/nginx/http.d/default.conf.template

VOLUME /media/data

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -q --spider -S http://127.0.0.1:8080/ 2>&1 | grep -qE "HTTP/1\.[01] (200|401)"

USER nginx

STOPSIGNAL SIGQUIT

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "nginx", "-g", "daemon off; pid /var/lib/nginx/nginx.pid;" ]
