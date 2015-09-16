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

Edit docker-compose.yml.
https://github.com/RestyaPlatform/board/releases

```yaml
environment:
    RESTYABOARD_VERSION: vX.Y.Z
```

### Notice
If you want to install a higher than source version, it may not work, perhaps.


License
------------------------------

[OSL 3.0](LICENSE.txt) fits in Restyaboard.
