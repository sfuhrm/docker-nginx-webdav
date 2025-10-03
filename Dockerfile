FROM alpine:latest

LABEL maintainer="sfuhrm"

EXPOSE 8080/tcp

RUN apk add --no-cache nginx nginx-mod-http-dav-ext apache2-utils && \
	sed -i 's%^user nginx;%# \0 %g' /etc/nginx/nginx.conf && \
    mkdir -p "/media/data" && \
    chown -R nginx:nginx "/media/data" && \
    mkdir -p "/etc/nginx/permissive" && \
    chown -R nginx:nginx "/etc/nginx/permissive" && \
    chmod 0750 "/etc/nginx/permissive" && \
    ln -sf /etc/nginx/permissive/default.conf /etc/nginx/http.d//default.conf && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

COPY --chmod=0755 entrypoint.sh /
COPY --chown=nginx --chmod=0644 webdav.conf /etc/nginx/permissive/default.conf

VOLUME /media/data

USER nginx

ENTRYPOINT [ "/entrypoint.sh"]
CMD [ "nginx",  "-g", "daemon off;" ]
