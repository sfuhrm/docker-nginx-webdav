FROM alpine:latest

LABEL maintainer="sfuhrm"

EXPOSE 80/tcp

RUN apk add --no-cache nginx nginx-mod-http-dav-ext apache2-utils && \
    mkdir -p "/media/data" && \
    chown -R nginx:nginx "/media/data"

COPY --chmod=0555 entrypoint.sh /
COPY webdav.conf /etc/nginx/http.d/default.conf

VOLUME /media/data

ENTRYPOINT [ "/entrypoint.sh"]
CMD [ "nginx",  "-g", "daemon off;" ]
