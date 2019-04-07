# Magento 2 Development

This is a Docker for Magento 2 development. It creates containers for MySQL, PHP, Redis that your Magento applications can use and share, and an nginx proxy that will route requests to your nginx container. It allows multiple Magento applications to run, sharing database, redis and base PHP image. Postfix and SSL support with Let's Encrypt coming soon.


## Configure

Configure the base containers here. 

- MySQL - etc/mysql/conf.d/my.cnf
- PHP - etc/php
- Redis - etc/redis

## Start
```
mkdir data/db/mysql
docker network create magento
docker-compose up -d
```

## Use
Use the Magento Develop project https://github.com/davidtay/magento-develop for example project composition.

