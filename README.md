Docker Restyaboard
==============================

Build Restyaboard using Docker.

* Restyaboard
  http://restya.com/board/


Build and Run Docker using docker-compose
------------------------------

``` bash
$ sudo yum install docker
$ sudo pip install -U docker-compose
$ git clone https://github.com/namikingsoft/docker-restyaboard.git
$ cd docker-restyaboard
$ COMPOSE_API_VERSION=1.18 docker-compose up -d
```


Include provisioning in AWS EC2
------------------------------

```bash
$ git clone https://github.com/namikingsoft/docker-restyaboard.git
$ cd docker-restyaboard
$ bundle install
$ cp .env.sample .env
$ vim .env
$ vagrant plugin install vagrant-aws
$ vagrant plugin install dotenv
$ vagrant up && bundle exec rake
```


Check URL
------------------------------

http://(SERVER_IP):1234


Other Command
------------------------------

### Rake provisioning

```bash
$ bundle exec rake provision
```

### Rake serverspec 

```bash
$ bundle exec rake spec
```
