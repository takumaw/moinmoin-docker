# MoinMoin Docker Image

(C)2018 WATANABE Takuma takumaw@sfo.kuramae.ne.jp

## What is MoinMoin?

MoinMoin is a free and open source wiki engine implemented in Python, with a large community of users.
See https://moinmo.in/ for more details.

## Usage


    $ docker run -p 8080:8080 takumaw/moinmoin

You can now access your instance via http://localhost:8080 in your browser.

You can also use the image with docker-compose, for example:

```
version: '3'
services:
  moin:
    image: takumaw/moinmoin
    ports:
      - 8080:8080
      - 3031:3031
      - 9191:9191
    volumes:
      - ./config:/usr/local/moin/config
      - ./data:/usr/local/moin/data
      - ./underlay:/usr/local/moin/underlay
```


## Image structure and configuration

This image has a MoinMoin setup with Nginx and uWSGI.

(See also: https://moinmo.in/HowTo/NginxWithUwsgi )

Image's volume folder structure is described below:

  * /usr/local/moin
    ... is a MoinMoin instance directory.
    * config/
    * data/
    * server/
    * underlay/
    * uwsgi.ini

If `config/`, `data/`, or `server/` is empty (e.g. it's first time to boot a container),
the container will automatically generate a new site under this directory
from `/usr/local/share/moin` with additional settings (done by `docker-entrypoint.sh`):

  * By default, user `root` is set as a superuser.
    * `root` is not exist by default. You can create via http://localhost/LanguageSetup?action=newaccount .
  * The `instance_dir` is set to `os.path.join(wikiconfig_dir, os.pardir)`,
    which points to `/usr/local/moin`.
  * All scripts under `/var/www/moin/server` is configured to use this wiki instance.

## Start, reload, and stop the container

To start a container:

    $ docker run -p 8080:8080 IMAGE_NAME

To reload:

    $ docker exec CONTAINER_ID uwsgi --reload /usr/local/moin/moin.pid

To stop:

    $ docker stop CONTAINER_ID

## Run `moin` command

The moin command installation path, `/usr/local/moin/server`, is in `PATH` variable, so you can run `moin` command by:

    $ docker exec CONTAINER_ID moin ...

For example:

    $ docker exec CONTAINER_ID moin account create --name=root --email=root@example.com --password=password

    $ docker exec CONTAINER_ID moin cli show FrontPage

See: https://moinmo.in/HelpOnMoinCommand

## See the stats of uWSGI

You can see the stats of uWSGI by `uwsgitop` installed on your computer.

    $ docker run -p 8080:8080 -p 9191:9191 IMAGE_NAME
    $ uwsgitop localhost:9191
