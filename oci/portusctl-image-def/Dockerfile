FROM ruby:2.6.0-stretch

# ------------------------------------------
#  Custom Commands that I added, inspired by
#  https://github.com/SUSE/Portus/issues/2244#issuecomment-584889394
# ------------------------------------------
#  Installs rake, and annotate, missing in
#  the SUSE/Portus Dockerfile
# ------------------------------------------




# --- because check_dn_.rb expects, I don't know why yet, a 2.6.0 ruby env.
# FROM ruby:2.6.5-stretch
# https://hub.docker.com/layers/ruby/library/ruby/2.6.5-stretch/images/sha256-159e7e054244af6aa75696a2a5141ccbcd12683e5b143dcb17077809d7d0c87d?context=explore
# FROM opensuse/ruby:2.6
# MAINTAINER is deprecated ...
# MAINTAINER SUSE Containers Team <containers@suse.com>

# I don't rely on opensuse/ruby anymore, in the stead, I rely on
# the official https://hub.docker.com/layers/ruby/library/ruby/
#


# We will build [portusctl] inside '/lab/portusctl'
RUN mkdir -p /lab/portusctl
# Once [portusctl] is built, we will copy the binary to '/lab/share'
RUN mkdir -p /lab/share
VOLUME /lab/share
WORKDIR /lab/portusctl

# ------------------------------------------------------v
# --- Ok, GOLANG STACK

# 1./ Install latest go version : picked from suse team dockerfile : [GOLANG_VERSION=1.10]
ARG GOLANG_VERSION=${GOLANG_VERSION:-'1.10'}
ARG GOLANG_OS=linux
ARG GOLANG_CPU_ARCH=amd64
# installing golang version
RUN curl https://dl.google.com/go/go${GOLANG_VERSION}.${GOLANG_OS}-${GOLANG_CPU_ARCH}.tar.gz -o go${GOLANG_VERSION}.${GOLANG_OS}-${GOLANG_CPU_ARCH}.tar.gz
RUN tar -C /usr/local -xzf go${GOLANG_VERSION}.${GOLANG_OS}-${GOLANG_CPU_ARCH}.tar.gz

# ARG PATH=$PATH:/usr/local/go/bin
# ENV PATH=$PATH:/usr/local/go/bin
# ARG PATH
# ENV PATH=$PATH
# RUN export PATH=$PATH:/usr/local/go/bin && go version

RUN PATH=$PATH:/usr/local/go/bin go version

ARG GOPATH=${GOPATH:-"$(pwd)"}
ENV GOPATH=${GOPATH:-"$(pwd)"}

ARG GOBIN=$GOPATH/bin
ENV GOBIN=$GOPATH/bin

# ---
# Can be a commit hash, or a tag, (but not a
# branch name, could be if we reset 'PORTUSCTL_COMMIT_ID', right
# after git checkout, the PORTUSCTL_COMMIT_ID is the
# last commit on the checked out branch.)
# ---
ENV PORTUSCTL_COMMIT_ID=${PORTUSCTL_COMMIT_ID:-'HEAD'}

# 2./ Then we install dev. dependencies
#
# ------------------------------------------
# ------------------------------------------
#  OPENSUSE packages installed using zypper
# ------------------------------------------
#  OPENSUSE           | DEBIAN
# ------------------------------------------
# go1.10              | I don't install that package, I installed a proper golang envrionnement in the stead, no OS package. See section above this table.
# gcc-c++             | g++, but I installed [build-essential], instead of [g++ / pattern / devel_basis OpenSUSE packages ]
# pattern             | ...no match found
# devel_basis         | ...no match found
# ------------------------------------------
# Notes on installed packages
# ---> the [devel_basis] [pattern] packages
#      are used for building stuff like
#      nokogiri.(Source : OpenSUSE Team)
# ------------------------------------------

RUN apt-get update -y && apt-get install -y curl \
                                            git \
                                            build-essential \
                                            go-md2man


COPY build.sh .
RUN chmod +x ./build.sh
ENTRYPOINT ["/lab/portusctl/build.sh"]


# --------------------------------------------------------------
# --------------------------------------------------------------
# ------ RELEASE AND BUILD ETC
# ------ SON BUILD FROM SOURCE BEUG DANS TOUS LES SENS
# --------------------------------------------------------------
# --------------------------------------------------------------
# ------

# --- Tagging building releasing n publishing at runtime
# RUN git add --all && git commit -m "releasing-2.5.0-rc"
# RUN git tag 2.5.0 -m "releasing-2.5.0-rc"
