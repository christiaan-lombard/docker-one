# Docker One

My Docker notes and examples.



## Resources

 - [Docker Docs](https://docs.docker.com/) - Documentation
 - [Docker Hub](https://hub.docker.com/) - Images
 - [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
 - [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
 - [freecodecamp Tuturial Video](https://www.youtube.com/watch?v=fqMOX6JJhGo)
 - [A primer on PHP on Docker under Windows 10](https://www.pascallandau.com/blog/php-php-fpm-and-nginx-on-docker-in-windows-10/)

---

## Docker Commands

### **Manage Images** using `docker image`

- `docker image pull IMAGE` - Pull an image or a repository from a registry
  - alias `docker pull`
- `docker image build PATH | URL` - Build an image from a *Dockerfile*
  - alias `docker build`
  - option `--tag IMAGE:TAG [-t]` - Give the image a name and tag
  - example `docker build -t christiaan/docker-one .`
- `docker image ls` - List downloaded images
  - alias `docker images`
- `docker image rm IMAGE` - Delete an image
  - alias `docker rmi`

### **Manage Containers** using `docker container`

- `docker container run IMAGE [COMMAND] [ARGS]` - Run a command in a **new container**
  - alias `docker run`
  - Image will be pulled if it does not exist
  - example `docker run docker/whalesay cowsay Hello`
  - option `--rm` - Automatically remove the container when it exits
  - option `--detach [-d]` - Run container in background
  - option `--name CONTAINER` - Give the new container a name
  - option `--interactive [-i]` - Keep STDIN open (for interactive commands)
  - option `--tty [-t]` - Allocate a terminal (for interactive commands)
  - option `--publish PORT [-p]` - Specify port(s) to publish (forward)
  - option `--volume VOLUME [-v]` - Specify volumes to map
  - option `--env ENV [-e]` - Specify environment variables
  - option `--network NETWORK` - Connect container to a network
  - option `--volume VOLUME` -Mount a named volume (creates volume if not exists), or folder on the container
- `docker container ps` - List running containers
  - alias `docker ps`
  - option `--all [-a]` - List all including not running
- `docker container stop CONTAINER` - Stop a running container
  - alias `docker stop`
- `docker container rm CONTAINER` - Delete a container
  - alias `docker rm`
- `docker container inspect CONTAINER` - Display detailed information on one or more containers
  - alias `docker inspect` - Can be used with any docker object
- `docker container logs CONTAINER` - Fetch the logs of a container
  - alias `docker logs`
- `docker container prune` - Remove all stopped containers


### **Manage Network** with `docker netork`

A docker network allows docker containers on the same host to communicate with one another on an internal network.

IP addresses are issued to containers, by default, within the range `172.17.0.0/8`

- `docker network create` creates a new network
  - option `--driver [-d] DRIVER` - specify a driver
  - option `--subnet SUBNET` - specify a subnet in CIDR format eg. `182.18.0.0/16`
- `docker network ls` lists networks


**Examples:**

Create a new bridge (internal) network, named `foo-network`:
```sh
docker network create \
  --driver bridge \
  --subnet 182.18.0.0/16 \
  foo-network
```


### **Manage Volumes** with `docker volume`

- `docker volume create VOLUME_NAME` - create a new named volume


### **Arguments:**

- `CONTAINER` can be either a container id or container name
- `IMAGE` is the name of the image. Add `:TAG` to get a specific version tag.
- `PORT` specify port(s) to forward, eg. `50:5000` forwards port 50 on the host to port 5000 on the container.
- `VOLUME` specify volumes to mount, eg. `/dev/app:/var/www` mounts `/dev/app` folder on the host to `/var/www` on the container.
- `ENV` specify environment variable(s) for the container, eg. `APP_COLOR=blue`
- `NETWORK` specify a named network to connect a container to.
- `DRIVER` specify a network driver.
  - `bridge` (default) connect to internal network
  - `host` connect the container to the host's network
  - `none` disable networking
- `VOLUME` specify a volume to mount on a container, eg. `app_database:/var/lib/mysql` reffering to a named volume or `/home/dev/src:/var/www/app` to mount a folder.


---

## Docker Examples

Start container and run bash terminal in container:
```sh
docker run --name php --rm -d php:7.3-fpm
docker exec -it php bash

```


**Images for testing Docker**

- `kodekloud/simple-prompt-docker` - Test interactive docker container
  - eg. `docker run -it kodekloud/simple-prompt-docker`


---

## Dockerfile


- `FROM <image>[:<tag>]` creates a base layer from a Docker image.
- `COPY <src> <dest>` copy files from the src and add to the filesystem of the container.
- `RUN <command>` execute commands in a new layer.
  - or `RUN ["executable", "param1", "param2"]` (exec form)
- `ENTRYPOINT <command> <params..>` configure a container that will run as an executable
  - or `ENTRYPOINT ["executable", "param1", "param2"]` (exec form)
  - only one ENTRYPOINT instruction
  - when running the container the entrypoint command will be executed
  - all arguments after `docker run IMAGE <args>` specifies params for the entrypoint command, appended after the specified params
- `CMD <command> <params..>` specifies default command to run within the container.
  - or `CMD ["executable","param1","param2"]` (exec form, this is the preferred form)
  - or `CMD ["param1","param2"]` (as default parameters to ENTRYPOINT)
  - command and parameters are replaced by `docker run IMAGE <command> <params>`
  - only one CMD instruction

**Examples:**

Specify a entrypoint with default argument/parameter:

```Dockerfile
FROM ubuntu
ENTRYPOINT ["sleep"]
CMD ["5"]
```

`docker run image` will execute `sleep 5` by default.


---

## Docker Compose

Compose allows you to define multi-container docker applications using a YAML file.


1. Define the app environment with a `Dockerfile`
2. Define the services that make up the app in `docker-compose.yml`
3. Run `docker-compose up` to start and run the app

`docker-compose` commands:
- `docker-compose up` - Builds, (re)creates, starts, and attaches to containers for a service.
  - option `--detatch -[d]` to run in background
- `docker-compose down` - Stop and remove containers, networks, images, and volumes
- `docker-compose start` - Start containers
- `docker-compose kill` - Stop containers
- `docker-compose restart` - Restart containers


Example:

```yml
version: '2.0'
services:
  web:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - .:/code
      - logvolume01:/var/log
  redis:
    image: redis
volumes:
  logvolume01: {}
```

Define container instances to run using `service`:
- `image` - Image to use for the container
- `build` - Configuration options applied at build time.
  - specified either as a string containing a path to the build context (Dockerfile) eg. `./app-docker`
  - or, object with context:
    ```yml
    build:
      context: ./dir
      dockerfile: Dockerfile-alternate
      args:
        buildno: 1
    ```
- `ports` - Specify container exposed ports (forwarding)
  - eg.
  ```yml
  ports:
    - "3000"
    - "3000-3005"
    - "8000:8000"
    - "49100:22"
    - "127.0.0.1:8001:8001"
    - "6060:6060/udp"
  ```
