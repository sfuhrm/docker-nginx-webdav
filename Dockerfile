FROM alpine:latest

LABEL maintainer="sfuhrm"

EXPOSE 80/tcp

RUN apk add --no-cache --upgrade nginx nginx-mod-http-dav-ext apache2-utils curl && \
    mkdir -p "/media/data" && \
    chown -R nginx:nginx "/media/data" && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/* && \
    find / -xdev -type f -perm /6000 -exec chmod a-s {} +

COPY --chmod=0555 entrypoint.sh /
COPY --chown=root:root webdav.conf /etc/nginx/http.d/default.conf

VOLUME /media/data

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -E "200|401" || exit 1

ENTRYPOINT [ "/entrypoint.sh"]
CMD [ "nginx",  "-g", "daemon off;" ]
