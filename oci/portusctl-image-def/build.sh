#!/bin/bash


if [ "x$PORTUSCTL_COMMIT_ID" == "x" ]; then
  echo " The [PORTUSCTL_COMMIT_ID] must be set, to build PORTUSCTL from source"
  exit 1
fi;

if [ "x$PORTUSCTL_VERSION" == "x" ]; then
  echo " The [PORTUSCTL_VERSION] must be set, to build PORTUSCTL from source"
  exit 1
fi;

# export PORTUSCTL_COMMIT_ID=${PORTUSCTL_COMMIT_ID:-'HEAD'}
# export PORTUSCTL_VERSION=${PORTUSCTL_VERSION}

git clone https://github.com/openSUSE/portusctl
cd portusctl/

git checkout $PORTUSCTL_COMMIT_ID

export PATH=$PATH:/usr/local/go/bin
export GOPATH=$(pwd)/vendor
export GOBIN=$GOPATH/bin

echo "GOPATH=[$GOPATH]"
echo "GOBIN=[$GOBIN]"

go get gopkg.in/urfave/cli.v1


echo ''
echo '  ==>> Now installing dependency [cpuguy83/go-md2man], to build [portusctl]'
echo ''

go get github.com/cpuguy83/go-md2man/md2man

echo ''
echo '  ==>> The error about [cpuguy83/go-md2man] is expected, and wont prevent building [portusctl]'
echo '       This imperfection in the [portusctl] build from source will soon be corrected by the pokus dev team'
echo ''

# -----
# Correcting a few bizarre bugs about md2man
mkdir -p /lab/portusctl/portusctl/vendor/src/github.com/cpuguy83/go-md2man/v2/ && cp -fR /lab/portusctl/portusctl/vendor/src/github.com/cpuguy83/go-md2man/md2man /lab/portusctl/portusctl/vendor/src/github.com/cpuguy83/go-md2man/v2/



make install


echo "building portusctl from source worked"

./vendor/bin/portusctl --version

cp ./vendor/bin/portusctl /lab/share
