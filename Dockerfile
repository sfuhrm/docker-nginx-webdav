FROM alpine:3.19 AS builder

RUN apk add --no-cache openssl

FROM alpine:3.19

LABEL maintainer="sfuhrm"

RUN apk add --no-cache --upgrade nginx nginx-mod-http-dav-ext && \
    mkdir -p "/media/data" && \
    chown -R nginx:nginx "/media/data" && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    rm -rf /usr/share/nginx/html /var/lib/nginx/html /var/cache/apk/* /tmp/* /var/tmp/* && \
    find / -xdev -type f -perm /6000 -exec chmod a-s {} +

COPY --from=builder /usr/bin/openssl /usr/bin/openssl
COPY --chmod=0555 entrypoint.sh /
COPY --chown=root:root webdav.conf /etc/nginx/http.d/default.conf

VOLUME /media/data

EXPOSE 80/tcp

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --spider -S http://127.0.0.1/ 2>&1 | grep -E "HTTP/1\.[01] (200|401)"

ENTRYPOINT [ "/entrypoint.sh"]
CMD [ "nginx", "-g", "daemon off;" ]