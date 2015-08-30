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
$ vagrant up
```

Provisioning
------------------------------

```bash
$ bundle exec rake provision
```

Spec
------------------------------

```bash
$ bundle exec rake spec
```
