# MoinMoin Docker Image

(C)2018 WATANABE Takuma takumaw@sfo.kuramae.ne.jp

## What is MoinMoin

MoinMoin is a free and open source wiki engine implemented in Python, with a large community of users.
See <https://moinmo.in/> for more details.

## Usage

You can run with:

    $ docker run -p 8080:8080 takumaw/moinmoin

You can now access your MoinMoin instance at <http://localhost:8080>.

You can also use the image with docker-compose, for example:

```Dockerfile
version: '3'
services:
  moin:
    image: takumaw/moinmoin
    ports:
      - "8080:8080"
      - "3031:3031"
      - "9191:9191"
    volumes:
      - ./config:/usr/local/moin/config
      - ./data:/usr/local/moin/data
      - ./underlay:/usr/local/moin/underlay
```

## Image structure and configuration

This image has a MoinMoin instance on uWSGI.

The MoinMoin instance listens these ports by default:

* HTTP: 8080/tcp
* uWSGI Socket: 3031/tcp
* uWSGI Stats Server: 9191/tcp

You can configure uWSGI behaviour by mounting your own `uwsgi.ini` at `/usr/local/moin/uwsgi.ini`.

The image's directory structure is described below:

* /usr/local/moin/
    ... is a MoinMoin instance directory.
  * config/
  * data/
  * server/
  * underlay/
  * uwsgi.ini

If `config/`, `data/`, or `server/` is empty (e.g. it's first time to boot a container),
the container will automatically generate a new site under this directory
from `/usr/local/share/moin` with additional settings (done by `/docker-entrypoint.sh`):

* By default, user `Admin` is set as a superuser.
  * `Admin` is not exist by default. You can create via <http://localhost:8080/LanguageSetup?action=newaccount> .
* The `instance_dir` is set to `os.path.join(wikiconfig_dir, os.pardir)`, which points to `/usr/local/moin`.
* All scripts under `/var/www/moin/server` is configured to use this wiki instance.

## Start, reload, and stop the container

Start a container:

    $ docker run -p 8080:8080 IMAGE_NAME

Reload MoinMoin instance:

    $ docker exec CONTAINER_ID uwsgi --reload /usr/local/moin/moin.pid

Stop the container:

    $ docker stop CONTAINER_ID

## Run `moin` command

The moin command installation path, `/usr/local/moin/server`, is in `PATH` variable, so you can run `moin` command by:

    $ docker exec CONTAINER_ID moin ...

For example:

    $ docker exec CONTAINER_ID moin account create --name=Admin --email=admin@example.com --password=password
    $ docker exec CONTAINER_ID moin cli show FrontPage

See <https://moinmo.in/HelpOnMoinCommand> for MoinMoin commands.

## See the stats of uWSGI

You can see the stats of uWSGI by `uwsgitop` installed on your computer.

    $ docker run -p 8080:8080 -p 9191:9191 takumaw/moinmoin
    $ uwsgitop localhost:9191
