# Magento 2 Docker

This is a Docker for Magento 2 development. It creates containers for MySQL, PHP, Redis that 
your Magento applications can use and share, and an nginx proxy that will route requests to 
your nginx container. It allows multiple Magento applications to run, sharing database, redis 
and base PHP image.

## Configure

Configure the base containers here. 

- MySQL - etc/mysql/conf.d/my.cnf
- PHP - etc/php
- Redis - etc/redis
- RabbitMQ

## Start
```
mkdir data/db/mysql
mkdir data/rabbitmq
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

## SSL
Create a certificate authority (CA) certificate for your organization. This CA certificate 
will then authenticate any server certificate you set up. Edit the `etc/nginx/certs/root.cnf` 
file and add your company info. Then generate the private key and certificate:

``` 
cd etc/nginx/certs
openssl req -x509 -new -keyout root.key -out root.crt -config root.cnf
```

On a Mac, double click the root.crt file to open Keychain Access where you can trust it 
to accept server certificates signed with its key. 

To set up a server certificate, copy 
the `etc/nginx/certs/server.cnf` to `etc/nginx/certs/www.mysite.local.cnf` adding in the 
host and domain of the server you want to set up:

```
cd etc/nginx/certs
cp server.cnf www.mysite.local.cnf
vi www.mysite.local.cnf
```

Generate the server key and certificate and then copy to your project's nginx certs directory:

```
cd etc/nginx/certs
openssl req -nodes -new -keyout www.mysite.local.key -out www.mysite.local.csr -config www.mysite.local.cnf
openssl x509 -req -in www.mysite.local.csr -CA root.crt -CAkey root.key -set_serial 123 -out www.mysite.local.crt -extfile www.mysite.local.cnf -days 365 -extensions x509_ext
cp www.mysite.local.key www.mysite.local.crt ~/Documents/Projects/mysite/etc/nginx/certs
```

## RabbitMQ
If your docker environment is on another server from your development environment, 
in `etc/rabbitmq/conf/rabbitmq.conf` uncomment line 70 and set `loopback_users.guest = true`. 
Restart the container `docker-compose restart rabbitmq` to reload the configuration.

Log into the RabbitMQ admin: http://192.168.0.112:15672/#/users as the guest/guest user. 
Create a user for yourself. Log out as guest and log back in as your user. Delete the 
guest user. Then create a user for Magento which has permissions to access virtual hosts.

Add the Magento user and to `app/etc/env.php`:

```
    'queue' => [
        'amqp' => [
            'host' => 'rabbitmq',
            'port' => '5672',
            'user' => 'magento',
            'password' => 'magento',
            'virtualhost' => '/'
        ]
    ],
```
