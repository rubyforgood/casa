# Development setup using Docker

After you install Docker, please follow either the automatic setup or the manual
setup. If you are new to Docker, it is recommended that you follow the manual
setup.

## Installing Docker
Install [Docker Community Edition](https://docs.docker.com/install/) if it is not already installed.

## Automatic Setup
The automatic setup explained here relies on Bash scripts in the docker directory to execute the most basic and frequent tasks in Docker.  There is substantially less typing to do under the automatic setup than under the manual setup.

### Initial setup
1. Clone the repository to your local machine: `git clone https://github.com/rubyforgood/casa.git` or create a fork in GitHub if you don't have permission to commit directly to this repo.
2. Change into the application directory: `cd casa`
3. Run `docker/build` to build the app, seed the database, run the local web server (in a detached state), run the test suite, and log the screen outputs of these processes in the log directory.  The web application will be available at http://localhost:3000.
4. Run `docker/test` to run the test suite and log the screen output in the log directory.
5. If you reboot the machine, restart Docker, or stop any services, the tests and many other functions will not work.  Please run `docker/server` to restart the app and allow the tests and other functions to work.

### Other Automated Scripts
* Run `docker/seed` to reseed the database.
* Run `docker/server` to restart the local web server (in a detached state).
* Run `docker/nukec` to delete all of the Docker containers.
* Run `docker/nuke` to delete all Docker containers, Docker networks, and Docker images.
* Run `docker/console` to start the Rails Console.
* Run `docker/sandbox` to start the Rails Sandbox.
* Run `docker/brakeman` to run the Brakeman security tool, which checks for security vulnerabilities.
* Use the `docker/run` script to run any command within the Rails Docker container.  For example, entering `docker/run cat /etc/os-release` executes the command `cat /etc/os-release` within the Rails Docker container.

## Manual Setup
The manual setup instructions walk you through building the images and starting
the containers using Docker Compose commands directly. This setup method is particularly
recommended if you are new to Docker.

### Initial setup
The following commands should just be run for the initial setup only. Rebuilding the docker images is only necessary when upgrading, if there are changes to the Dockerfile, or if gems have been added or updated.
1. Clone the respository to your local machine: `git clone https://github.com/rubyforgood/casa.git` or create a fork in GitHub if you don't have permission to commit directly to this repo.
2. Change into the application directory: `cd casa`
3. Run `docker compose build` to build images for all services.
4. Run `docker compose run --rm web bundle install` to install ruby dependencies
5. Run `docker compose run --rm web rails db:reset` to create the dev and test databases, load the schema, and run the seeds file.
6. Run `docker compose run --rm web yarn` to install javascript dependencies
7. Run `docker compose run --rm web yarn build` to bundle javascript assets
8. Run `docker compose run --rm web yarn build:css` to bundle the css
9. Run `docker compose up` to start all the remaining services. Or use `docker compose up -d` to start containers in the background.
10. Run `docker compose ps` to view status of the containers. All should have state "Up". Check the [logs](#viewing-logs) if there are any containers that did not start.
11. The web application will be available at http://localhost:3000

### For ongoing development:
* Run `docker compose up -d` to start all services.
* Run `docker compose ps` to view status of containers.
* Run `docker compose stop` to stop all services.
* Run `docker compose restart web` to restart the web server.
* Run `docker compose rm <service>` to remove a stopped container.
* Run `docker compose rm -f <service>` to force remove a stopped container.
* Run `docker compose up -d --force-recreate` to start services with new
   containers.
* Run `docker compose build web` to build a new image for the web service.
   After re-building an image, run `docker compose up -d --force-recreate web`
   to start a container running the new image.
* Run `docker compose down -v` to stop and remove all containers, as well as
   volumes and networks. This command is helpful if you want to start with a
   clean slate.  However, it will completely remove the database and you will
   need to go through the database setup steps again above.

#### Running commands
In order to run rake tasks, rails generators, bundle commands, etc., they need to be run inside the container:
```
$ docker compose exec web rails db:migrate
```

If you do not have the web container running, you can run a command in a one-off container:

```
$ docker compose run --rm web bundle install
```

However, when using a one-off container, make sure the image is up-to-date by
running `docker compose build web` first.  If you have been making gem updates
to your container without rebuilding the image, then the one-off container will
be out of date.

#### Running webpack dev server
To speed compiling of assets, run the webpack dev server in a separate terminal
window:

```
$ docker compose exec web bin/webpack-dev-server
```


#### Viewing logs
To view the logs, run:
```
$ docker compose logs -f <service>
```

For example:
```
$ docker compose logs -f web
```

#### Accessing services
##### Postgres database
```
$ docker compose exec database psql -h database -Upostgres casa_development
```

##### Rails console
```
$ docker compose exec web rails c
```

### Testing Suite
Run the testing suite from within the container:

```
$ docker compose exec web rspec spec -fd
```

For a shorter screen output from running the testing suite from within the container:

```
$ docker compose exec web rspec spec
```

System tests will generate a screenshot upon failure. The screenshots can be
found in the local `tmp/screenshots` directory which maps to the
`/usr/src/app/tmp/screenshots` directory inside the container.

#### Watching tests run

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

## Troubleshooting
### Nokogiri not found on some macs
https://stackoverflow.com/questions/70963924/unable-to-load-nokogiri-in-docker-container-on-m1-mac
