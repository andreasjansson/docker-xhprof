Docker-XHProf
=============

Docker image created from [preinheimer/xhprof](https://github.com/preinheimer/xhprof). Trusted build at https://index.docker.io/u/andreasjansson/docker-xhprof/, pull from andreasjansson/docker-xhprof.

XHProf is a really nice PHP profiling tool developed by Facebook. P Reinheimer's patch adds a GUI with customisable backends.

This Docker image stores the profiling in MySQL. The GUI sits behind Apache, with optional HTTP auth. The image also gives you SSH access, so you can access the insides of the container while it's running.

Docker stuff
------------

### Environment variables

* DB_USER
  - XHProf database username, **required**

* DB_PASS
  - XHProf database password **required**

* HTTP_AUTH_USER
  - HTTP authentication username (optional)

* HTTP_AUTH_PASS
  - HTTP authentication password (optional)

### Ports

* 80
  - The web GUI (should probably be exposed)

* 3306
  - The database (should also probably be exposed)

* 22
  - SSH access, user: root, password: root (should definitely *not* be exposed)
