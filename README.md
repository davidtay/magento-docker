# Magento 2 Development

This is a Docker for Magento 2 development. It creates containers for MySQL, PHP, Redis that your Magento applications can use and share, and an nginx proxy that will route requests to your nginx container. It allows multiple Magento applications to run, sharing database, redis and base PHP image. Postfix and SSL support with Let's Encrypt coming soon.


## Configure

Configure the base containers here. 

- MySQL - etc/mysql/conf.d/my.cnf
- nginx-proxy - etc/nginx/conf.d/default.conf
- PHP - etc/php
- Redis - etc/redis

## Start

`docker-compose up -d`

## Use

Basically, you will just need to start up your application's (mysite) own nginx and PHP, that is an instance of the image of the running PHP container.

- Create your Magento application `mysite` and docker compose file: 

```
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
        - "./www:/var/www/local.mysite.com" 
```

- The `VIRTUAL_HOST` environment variable will be picked up by the nginx proxy container.
- Create an image of the running PHP container (container name is php): `docker commit php mysite/php`
- Configure etc/nginx/conf.d/default.conf for your site:

```
#Nginx configuration

upstream fastcgi_backend {
# use tcp connection
   server  mysite_php:9001;
# or socket
   # server   unix:/run/php/php7.1-fpm.sock;
}

server {
    server_name local.mysite.com;
    listen 80;
    listen [::]:80;
    
    access_log /dev/stdout;
    error_log  /dev/stderr;
     
    index index.php;
    root /var/www/local.mysite.com;
}
```

- Start the `mysite` application: `docker-compose up -d`
- Install Magento (you may have to install composer):
```
docker exec -it mysite_php bash
root@03a74a2e90e1:/var/www# composer create-project --repository=https://repo.magento.com/ magento/project-enterprise-edition local.mysite.com
    Authentication required (repo.magento.com):
      Username: 50cf47429287dr299f82e817a7cd1279
      Password: 
```
https://devdocs.magento.com/guides/v2.3/install-gde/composer.html
- Setup Magento
```
cd local.mysite.com
php bin/magento setup:install \
> --base-url=http://local.mysite.com/ \
> --db-host=mysqldb --db-name=mysite \
> --db-user=root --db-password=root \
> --admin-firstname=John --admin-lastname=Doe \
> --admin-email=jdoe@mysite.com --admin-user=jdoe --admin-password=testing123 \
> --language=en_US --currency=USD --timezone=America/New_York --use-rewrites=1
```
- Sample Magento configuration: 
```
<?php
return [
    'backend' => [
        'frontName' => 'admin_16yq99'
    ],
    'db' => [
        'connection' => [
            'indexer' => [
                'host' => 'mysqldb',
                'dbname' => 'mysite',
                'username' => 'root',
                'password' => 'root',
                'model' => 'mysql4',
                'engine' => 'innodb',
                'initStatements' => 'SET NAMES utf8;',
                'active' => '1',
                'persistent' => NULL
            ],
            'default' => [
                'host' => 'mysqldb',
                'dbname' => 'mysite',
                'username' => 'root',
                'password' => 'root',
                'model' => 'mysql4',
                'engine' => 'innodb',
                'initStatements' => 'SET NAMES utf8;',
                'active' => '1'
            ]
        ],
        'table_prefix' => ''
    ],
    'crypt' => [
        'key' => '9c21fedc8395b6d91c494578cd15a621'
    ],
    'resource' => [
        'default_setup' => [
            'connection' => 'default'
        ]
    ],
    'x-frame-options' => 'SAMEORIGIN',
    'MAGE_MODE' => 'developer',
    'cache_types' => [
        'config' => 1,
        'layout' => 1,
        'block_html' => 1,
        'collections' => 1,
        'reflection' => 1,
        'db_ddl' => 1,
        'eav' => 1,
        'customer_notification' => 1,
        'config_integration' => 1,
        'config_integration_api' => 1,
        'target_rule' => 1,
        'full_page' => 1,
        'translate' => 1,
        'config_webservice' => 1,
        'compiled_config' => 1
    ],
    'session' => [
        'save' => 'redis',
        'redis' => [
            'host' => 'redis_session',
            'port' => '6379',
            'password' => '',
            'read_timeout' => '300',
            'timeout' => '300',
            'persistent_identifier' => '',
            'compression_threshold' => '2048',
            'compression_library' => 'gzip',
            'log_level' => '7',
            'max_concurrency' => '100',
            'break_after_frontend' => '5',
            'break_after_adminhtml' => '30',
            'first_lifetime' => '600',
            'bot_first_lifetime' => '60',
            'bot_lifetime' => '7200',
            'disable_locking' => '0',
            'min_lifetime' => '60',
            'max_lifetime' => '2592000'
        ]
    ],
    'cache' => [
        'frontend' => [
            'default' => [
                'backend' => 'Cm_Cache_Backend_Redis',
                'backend_options' => [
                    'server' => 'redis',
                    'port' => '6379',
                    'persistent' => 'cache-db0',
                    'database' => '0',
                    'password' => '',
                    'force_standalone' => '0',
                    'connect_retries' => '1',
                    'read_timeout' => '10',
                    'automatic_cleaning_factor' => '0',
                    'compress_data' => '1',
                    'compress_tags' => '1',
                    'compress_threshold' => '20480',
                    'compression_lib' => 'gzip',
                    'use_lua' => '0'
                ]
            ],
            'page_cache' => [
                'backend' => 'Cm_Cache_Backend_Redis',
                'backend_options' => [
                    'server' => 'redis_fpc',
                    'port' => '6379',
                    'persistent' => 'cache-db1',
                    'database' => '1',
                    'password' => '',
                    'force_standalone' => '0',
                    'connect_retries' => '1',
                    'lifetimelimit' => '57600',
                    'compress_data' => '0'
                ]
            ]
        ]
    ],
    'system' => [
        'default' => [
            'dev' => [
                'debug' => [
                    'debug_logging' => '0'
                ]
            ]
        ]
    ],
    'install' => [
        'date' => 'Mon, 10 Feb 2019 18:15:29 +0000'
    ]
];
```


