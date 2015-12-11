Docker Restyaboard
==============================

Build Restyaboard in Docker.

* Restyaboard  
  http://restya.com/board/

* Docker  
  https://www.docker.com/


Quick Start
------------------------------

Build image and Run container using docker-compose.

``` bash
git clone https://github.com/namikingsoft/docker-restyaboard.git
cd docker-restyaboard

docker-compose up -d
```

Please wait a few minutes to complete initialize.


Check URL
------------------------------

```
http://(ServerIP):1234

Username: admin
Password: restya

Username: user
Password: restya
```


Change Restyaboard Version
------------------------------

Edit restyaboard/Dockerfile.  
Available version is https://github.com/RestyaPlatform/board/releases

```
ENV restyaboard_version=REPLACE_ME
```

In case of upgrade version, rebuild image and recreate container.

```sh
docker-compose build
docker-compose up -d
```

If you want to upgrade database, e.g.
(recommend to backup database before upgrade)

```sh
docker-compose run --rm restyaboard bash

export PGHOST=$POSTGRES_PORT_5432_TCP_ADDR
export PGPORT=$POSTGRES_PORT_5432_TCP_PORT
export PGUSER=$POSTGRES_ENV_POSTGRES_USER
export PGPASSWORD=$POSTGRES_ENV_POSTGRES_PASSWORD
...
psql -d restyaboard -f sql/upgrade-0.1.3-0.1.4.sql
psql -d restyaboard -f sql/upgrade-0.1.4-0.1.5.sql
...
exit
```


License
------------------------------

[OSL 3.0](LICENSE.txt) fits in Restyaboard.
