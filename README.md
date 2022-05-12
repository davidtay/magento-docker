# Magento 2 Docker

This is a Docker for Magento 2 development. It creates containers for MySQL, PHP, Redis that 
your Magento applications can use and share, and Varnish/Hitch that will route requests to 
your nginx containers. It allows multiple Magento applications to run, sharing database, Redis, 
Varnish and base PHP image.

## Configure

Configure the base containers here. 

- Elasticsearch - etc/elasticsearch/config/elasticsearch7.yml
- MySQL - etc/mysql/conf.d/my.cnf
- PHP - etc/php
- RabbitMQ - etc/rabbitmq/conf/rabbitmq.conf
- Redis - etc/redis
- Varnish - etc/varnish/default.vcl

## Start
```
mkdir data/db/mysql
mkdir data/rabbitmq
docker network create magento
docker-compose up -d
```

## Projects
Use the Magento Develop project https://github.com/davidtay/magento-develop for example 
project composition.

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
cat www.mysite.local.crt www.mysite.local.key > www.mysite.local.pem
cp www.mysite.local.key www.mysite.local.crt ~/Documents/Projects/mysite/etc/nginx/certs
```

## RabbitMQ
Log into the RabbitMQ admin: http://192.168.0.112:15672/#/users as the guest/guest user. 
Create a user for yourself. Log out as guest and log back in as your user. Delete the 
guest user. Then create a user for Magento which has permissions to access virtual hosts.

Add the Magento user to `app/etc/env.php`:

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

## Elasticsearch
Url to the elasticsearch-head admin: http://localhost:9100/