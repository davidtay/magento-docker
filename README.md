# Magento 2 Docker

This is a Docker for Magento 2 development. It creates containers for MySQL, PHP, Redis that 
your Magento applications can use and share, and an nginx proxy that will route requests to 
your nginx container. It allows multiple Magento applications to run, sharing database, redis 
and base PHP image. Postfix and SSL support with Let's Encrypt coming soon.


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
Use the Magento Develop project https://github.com/davidtay/magento-develop for example 
project composition.

## Scripts
Some [scripts](scripts/) for syncing a project's codebase between servers. For example, 
I have my containers on another server from my local development environment. I sync the 
codebases between the servers using Unison.