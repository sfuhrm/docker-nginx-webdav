FROM alpine:latest

LABEL maintainer="sfuhrm"

EXPOSE 80/tcp
COPY entrypoint.sh /

RUN apk add nginx nginx-mod-http-dav-ext apache2-utils && \
    mkdir -p "/media/data" && \
    chown -R nginx:nginx "/media/data" && \
    chmod +x /entrypoint.sh

COPY webdav.conf /etc/nginx/http.d/default.conf

VOLUME /media/data

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh"]
CMD [ "nginx",  "-g", "daemon off;" ]
