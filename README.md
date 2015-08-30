Docker Restyaboard
==============================

Restyaboard
http://restya.com/board/


Install
------------------------------

```bash
$ bundle install
$ cp .env.sample .env
$ vim .env
$ vagrant plugin install vagrant-aws
$ vagrant plugin install dotenv
$ vagrant up && bundle exec rake
```

Rake
------------------------------

### Provisioning

```bash
$ bundle exec rake provision
```

### ServerSpec 

```bash
$ bundle exec rake spec
```
