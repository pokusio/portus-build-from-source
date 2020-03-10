# Pokus! [Portus](#) : The Build From Source

A complete recipe to build portus from source, on a debian stack, instead of opensuse


# Building `portus` from source

Portus is a `Ruby On Rails` application.

As such, The initial OpenSUSE Dev Team designed it to be run using an application server, [`puma`](ccc) pretty much the analog of a Jee Server, but for `Rails`.


I designed this build process, folowing those two priniciples :
* I transposed this `Opensuse Leap`-based `Dockerfile` , to a Debian based stack, able to run the whole of the `bundler` commands of `Portus`' build process.
* I want to build and run `Portus`, like any other `Ruby On Rails` application, and with state-of-the-art best practices.

The build process consist essentially of dependency resolution, and "bundling", using a standard Ruby package manager, called [`bundler`](https://bundler.io/)


```bash
export WORK_FOLDER=~/.buildfromsrc.portus
export SSH_URI_TO_THIS_RECIPE_GIT=git@gitlab.com:second-bureau/pegasus/docker/portus-autopilot.git
git clone $SSH_URI_TO_THIS_RECIPE_GIT $WORK_FOLDER

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

echo "Now building an image"
docker-compose build portus
```

# Building `portusctl` from source


* Build and run :
```bash
docker-compose down --rmi all && docker-compose up -d portusctl && docker-compose logs -f portusctl
```

* Wiping everything out :
```bash
docker-compose down --rmi all && docker system prune -f --all && docker-compose up -d portusctl && docker-compose logs -f portusctl
```
