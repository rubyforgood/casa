# Development setup using Docker

## Initial setup
The following commands should just be run for the initial setup only. Rebuilding the docker images is only necessary when upgrading, if there are changes to the Dockerfile, or if gems have been added or updated.
1. Install [Docker Community Edition](https://docs.docker.com/install/) if it
   is not already installed.
3. Clone the respository to your local machine: `git clone
   https://github.com/rubyforgood/casa.git` or create a fork in GitHub if you
   don't have permission to commit directly to this repo.
4. Change into the application directory: `cd casa`
5. Run `docker-compose build` to build images for all services.
6. Run `docker-compose up -d database` to start the database service.
7. Run `docker-compose run --rm web rails db:reset` to create the dev and test
   databases, load the schema, and run the seeds file.
8. Run `docker-compose up -d` to start all the remaining services.
9. Run `docker-compose ps` to view status of the containers. All should have
   state "Up". Check the [logs](#viewing-logs) if there are any containers that
   did not start.
10. The web application will be available at http://localhost:3000

## For ongoing development:
1. Run `docker-compose up -d` to start all services.
1. Run `docker-compose up -d --force-recreate` to start services with new
   containers.
1. Run `docker-compose build web` to build a new image for the web service.
   After re-building an image, run `docker-compose up -d --force-recreate web`
   to start a container running the new image.
5. Run `docker-compose ps` to view status of containers.
1. Run `docker-compose stop` to stop all services.
1. Run `docker-compose rm <service>` to remove a stopped container.
1. Run `docker-compose rm -f <service>` to force remove a stopped container.
1. Run `docker-compose restart web` to restart the web server.
4. Run `docker-compose down -v` to stop and remove all containers, as well as
   volumes and networks. This command is helpful if you want to start with a
   clean slate.  However, it will completely remove the database and you will
   need to go through the database setup steps again above.

### Running commands
In order to run rake tasks, rails generators, bundle commands, etc., they need to be run inside the container:
```
$ docker-compose exec web rails db:migrate
```

If you do not have the web container running, you can run a command in a one-off container:

```
$ docker-compose run --rm web bundle install
```

However, when using a one-off container, make sure the image is up-to-date by
running `docker-compose build web` first.  If you have been making gem updates
to your container without rebuilding the image, then the one-off container will
be out of date.

### Viewing logs
To view the logs, run:
```
$ docker-compose logs -f <service>
```

For example:
```
$ docker-compose logs -f web
```

### Accessing services
#### Postgres database
```
$ docker-compose exec database psql -h database -Upostgres casa_development
```

#### Rails console
```
$ docker-compose exec web rails c
```

## Testing Suite
Run the testing suite from within the container:

```
$ docker-compose exec web rspec spec -fd
```

System tests will generate a screenshot upon failure. The screenshots can be
found in the local `tmp/screenshots` directory which maps to the
`/usr/src/app/tmp/screenshots` directory inside the container.

### Watching tests run

You can view the tests in real time by using a VNC client and temporarily
switching to the `selenium_chrome_in_container` driver set in
[spec/spec_helper.rb](https://github.com/rubyforgood/casa/blob/master/spec/spec_helper.rb).
For example, you can change this:

```
    if ENV["DOCKER"]
      driven_by :selenium_chrome_headless_in_container
```

to this:

```
    if ENV["DOCKER"]
      # driven_by :selenium_chrome_headless_in_container
 `    driven_by :selenium_chrome_in_container
```

Mac OS comes with a built-in screen sharing application, "Screen Sharing".
On Ubuntu-based Linux, the VNC client application "Vinagre" (aka "Remote Desktop Viewer")
is commonly used, and can be installed with `sudo apt install vinagre`.

You can open the VNC client application and configure it directly, but in both operating systems
it's probably easier to click on [vnc://localhost:5900](vnc://localhost:5900) 
(or paste that into your browser's address bar) and let the browser launch the VNC client with
 the appropriate parameters for you.

The VNC password is `secret`.

Run the spec(s) from the command line and you can see the test running in the browser through the VNC client.
