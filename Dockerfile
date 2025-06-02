FROM alpine:latest

LABEL maintainer="sfuhrm"

EXPOSE 8080/tcp
COPY entrypoint.sh /

RUN apk add --no-cache nginx nginx-mod-http-dav-ext apache2-utils && \
    mkdir -p "/media/data" && \
    chown -R nginx:nginx "/media/data" && \
    chmod +x /entrypoint.sh && \
	sed -i 's%user nginx;% %g' /etc/nginx/nginx.conf && \
    touch /etc/nginx/htpasswd && \
    chown nginx /etc/nginx/htpasswd

COPY webdav.conf /etc/nginx/http.d/default.conf

VOLUME /media/data

USER nginx

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh"]
CMD [ "nginx",  "-g", "daemon off;" ]
