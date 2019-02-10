# Magento 2 Docker

This is a Docker for Magento 2 local development. It creates containers for MySQL, PHP, Redis that your Magento applications can use and share, and an nginx proxy that will route requests to your nginx container. It allows multiple Magento applications to run, sharing database, redis and base PHP image. Postfix and SSL support with Let's Encrypt coming soon.


## Configure

- MySQL - etc/mysql/conf.d/my.cnf
- nginx proxy - etc/nginx/conf.d/local.mysite.com.conf
- PHP - etc/php
- Redis - etc/redis
- 

## Start

`docker-compose up -d`

## Use

Basically, you will just need to start up your application's (mysite) own nginx and PHP, that is an instance of the image of the running PHP container.

- Create your Magento application `mysite` and docker compose file: ```
version: '3'
networks:
  default: 
    external:
        name: nginx-proxy
services:
    nginx: 
      image: nginx:alpine
      container_name: mysite_nginx
      volumes:
        - "./www:/var/www/local.mysite.com"
        - "./etc/ssl:/etc/ssl"
        - "./etc/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf"
      expose:
        - "80"
      environment:
        VIRTUAL_HOST: local.mysite.com
      restart: always
    php: 
      image: mysite/php
      container_name: mysite_php
      volumes:
        - "./etc/php/php.ini:/usr/local/etc/php/conf.d/php.ini"
        - "./etc/php/www.conf:/usr/local/etc/php-fpm.d/www.conf"
        - "./www:/var/www/local.mysite.com" ```
- Create an image of the running PHP container: `docker commit php mysite/php`
- Start the `mysite` application: `docker-compose up -d`


