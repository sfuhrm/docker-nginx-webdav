FROM alpine:latest

LABEL maintainer="sfuhrm"

EXPOSE 8080/tcp

RUN apk add --no-cache nginx nginx-mod-http-dav-ext apache2-utils && \
    mkdir -p "/media/data" && \
    chown -R nginx:nginx "/media/data" && \
    mkdir -p "/etc/nginx/permissive" && \
    chown -R nginx:nginx "/etc/nginx/permissive" && \
    chmod 0750 "/etc/nginx/permissive" && \
    ln -sf /etc/nginx/permissive/default.conf /etc/nginx/http.d && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

COPY --chmod=0555 entrypoint.sh /
COPY --chown=nginx --chmod=0640 webdav.conf /etc/nginx/permissive/default.conf

VOLUME /media/data

USER nginx

ENTRYPOINT [ "/entrypoint.sh"]
CMD [ "nginx",  "-g", "daemon off;" ]
