# Nginx WebDav Server (built from the Alpine image)

[![Docker Image CI](https://github.com/sfuhrm/docker-nginx-webdav/actions/workflows/docker-image.yml/badge.svg)](https://github.com/sfuhrm/docker-nginx-webdav/actions/workflows/docker-image.yml)
![Docker Image Size](https://img.shields.io/docker/image-size/sfuhrm/docker-nginx-webdav)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Incredibly secure, fast and light WebDav Server, built from Alpine image - bare minimum with no bells and whistles.

> This is a fork of https://github.com/maltokyo/docker-nginx-webdav with the following changes:
> * replacing the base image to Alpine Linux,
> * improving the entrypoint script,
> * reducing the image layers,
> * adding Github Actions build / push with automatic daily image building

## How to use this image
```console
$ docker run --name keepass-webdav -p 80:80 -v /path/to/your/keepass/files/:/media/data -d sfuhrm/docker-nginx-webdav
```

Or use the [docker-compose](./docker-compose.yml) file included in this repository.

No built-in TLS support. Reverse proxy with TLS recommended.

## Volumes
- `/media/data` - served directory, needs to be accessible to the `nginx` user with uid `100` and gid `101`.

## Authentication

### With environment variables

To restrict access to only authorized users (recommended), you can define two environment variables: `$USERNAME` and `$PASSWORD`
```console
$ docker run --name webdav -p 80:80 -v /path/to/your/shared/files/:/media/data -e USERNAME=webdav -e PASSWORD=webdav -d maltokyo/docker-nginx-webdav

### With files variables

If you want to pass username and password in files like Docker secrets, you can define two environment variables: `$USERNAME_FILE` and `$PASSWORD_FILE`

## Docker compose

Or use docker-compose example with secret
```nano
version: "3.9"
name: webdav
secrets:
  USERNAME_SC:
    file: <path-to-your-secret>/username.secret.txt
  PASSWORD_SC:
    file:  <path-to-your-secret>/password.secret.txt
services:
  docker-nginx-webdav:
    image: sfuhrm/docker-nginx-webdav
    build: .
    container_name: webdav
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    ports:
      - "80:80"
    volumes:
      - "<path-you-want-to-share>:/media/data"
    secrets:
      - USERNAME_SC
      - PASSWORD_SC
    environment:
      - USERNAME_FILE=/run/secrets/USERNAME_SC
      - PASSWORD_FILE=/run/secrets/PASSWORD_SC

```

(Inspired from https://github.com/jbbodart/alpine-nginx-webdav - but "upgraded" to debian-buster image with all WebDav functionality enabled to work perfectly with MacOS OSX and Windows 10)
