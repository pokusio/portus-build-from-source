
# Building `portus` from source


Portus is a `Ruby On Rails` application.

As such, The initial OpenSUSE Dev Team designed it to be run using an application server, [`puma`](https://puma.io/) pretty much the analog of a Jee Server, but for `Rails`.


I designed this build process, folowing those two priniciples :
* I transposed this `Opensuse Leap`-based `Dockerfile` , to a Debian based stack, able to run the whole of the `bundler` commands of `Portus`' build process.
* I want to build and run `Portus`, like any other `Ruby On Rails` application, and with state-of-the-art best practices.

The build process consist essentially of dependency resolution, and "bundling", using a standard Ruby package manager, called [`bundler`](https://bundler.io/)


```bash
export WORK_FOLDER=~/.buildfromsrc.portus
export SSH_URI_TO_THIS_RECIPE_GIT=git@github.com:pokusio/portus-build-from-source.git
export HTTP_URI_TO_THIS_RECIPE_GIT=https://github.com/pokusio/portus-build-from-source.git

# git clone $SSH_URI_TO_THIS_RECIPE_GIT $WORK_FOLDER
git clone $HTTP_URI_TO_THIS_RECIPE_GIT $WORK_FOLDER

cd $WORK_FOLDER/build-from-source

docker-compose build portus_frontend_buildfromsrc
# So we wait until building frontend has completed :
docker-compose up -d portus_frontend_buildfromsrc && docker-compose logs -f portus_frontend_buildfromsrc
echo "Now result of the build of frontend is in [$(pwd)/oci/portus-image-def/built-portus/]"
ls -allh $(pwd)/oci/portus-image-def/built-portus/

# --------------------------------------------
# Now we free disk space so we can
# build on as small a machine as possible.
# [$(pwd)/oci/portus-image-def/built-portus/]
# survives this clean up
#
docker-compose down --rmi all && docker system prune -f --all && docker system prune -f --volumes

echo "Result of the build of frontend in [$(pwd)/oci/portus-image-def/built-portus/] survives the disk space cleanup"
ls -allh $(pwd)/oci/portus-image-def/built-portus/

echo "Now building an OCI image in which The Portus Ruby On Rails app is built, and in which we can start Portus"
docker-compose build portus


echo "Now running The Portus Ruby On Rails app inside a container from the OCI built image containing Portus built and ready-to-run"
docker-compose up -d portus && docker-compose logs -f portus

```

* Now, the `/init` script is waiting for database to be reachable,
* So open a new shell session, change directory to the directory where your `docker-compose.yml` is, and execute this :

```bash
export WORK_FOLDER=~/.buildfromsrc.portus
cd $WORK_FOLDER

docker-compose exec -T portus bash -c 'bundler exec "pumactl -F /srv/Portus/config/puma.rb start"'
# docker exec -it portus-build-from-source_portus_1 bash -c 'bundler exec "pumactl -F /srv/Portus/config/puma.rb start"'
```

* You just started `Portus`, and it is just complaining about a few things, like you don't have a database. And inideed, there isno database, but you tested Portus actually starts.

# Building `portusctl` from source


* Build and run :
```bash
docker-compose down --rmi all && docker-compose up -d portusctl && docker-compose logs -f portusctl

PORTUSCTL_CPU_ARCH=$(cat .env |grep GOLANG_CPU_ARCH|awk -F '=' '{print $2}')
PORTUSCTL_OS=$(cat .env |grep GOLANG_OS|awk -F '=' '{print $2}')

echo "And now you have portusctl executable, built for ${PORTUSCTL_OS} on ${PORTUSCTL_CPU_ARCH} CPU arch. available here : "

ls -all portusctl/portusctl

./portusctl/portusctl --version
./portusctl/portusctl --help

```

# Checking The commits' Signature

All commits were signed by me, the author, Jean-Baptiste Lasselle, and :

* You can find my GPG public key at https://keybase.io/jblasselle
* Check that https://keybase.io verified that I am https://github.com/Jean-Baptiste-Lasselle
* Check that https://github.com guarantees https://github.com/Jean-Baptiste-Lasselle is the owner of https://github.com/pokusio
 
