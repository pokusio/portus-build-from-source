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

ENV COMPOSE=1

# Install the entrypoint of this image.
COPY init /
RUN chmod +x /init
WORKDIR /srv/Portus

# ------------------------------------------------------v
# --- Ok, At OpenSUSE , they wanted to just install
# --- dependencies from Gemfiles, but I have to modify
# --- it live, so I don't want my changes involved by my
# ---  'gem install' commands, to be wiped out
# ---
# COPY built-portus/Gemfile* ./
COPY built-portus/ .

RUN apt-get update -y && apt-get install -y curl


# 1./ Install latest go version : picked from suse team dockerfile : [GOLANG_VERSION=1.10]
ARG GOLANG_VERSION=1.10
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

RUN echo "[FINISHED] : Golang installation commands transposed from OPENSUSE to Debian"



# 2./ Then we install dev. dependencies
#
# ------------------------------------------
# ------------------------------------------
#  OPENSUSE packages installed using zypper
# ------------------------------------------
#  OPENSUSE           | DEBIAN
# ------------------------------------------
# ruby2.6-devel       | already installed in base image [ruby:2.6.5-stretch]
# libmariadb-devel    | libmariadb-dev
# postgresql-devel    | postgresql-server-dev-all
# nodejs              | [nodejs] Instead of just installing the package ... I install nodejs properly ?
# libxml2-devel       | libxml2-dev
# libxslt1            | libxslt1.1
# git-core            | git-core
# go1.10              | I don't install that package, I installed a proper golang envrionnement in the stead, no OS package. See section above this table.
# phantomjs           | phantomjs
# gcc-c++             | g++, but I installed [build-essential], instead of [g++ / pattern / devel_basis OpenSUSE packages ]
# pattern             | ...no match found
# devel_basis         | ...no match found
# ------------------------------------------
# Notes on installed packages
# ---> the [devel_basis] [pattern] packages
#      are used for building stuff like
#      nokogiri.(Source : OpenSUSE Team)
# ------------------------------------------
RUN apt-get install -y libmariadb-dev \
                       postgresql-server-dev-all \
                       nodejs \
                       libxml2-dev \
                       libxslt1.1 \
                       git-core \
                       phantomjs \
                       build-essential
RUN echo "[FINISHED] : packages installation commands transposed from OPENSUSE to Debian"



# ARG GEM_PATH="/usr/local:/usr/local/bin:/srv/Portus/vendor:/srv/Portus/vendor/bundle:/srv/Portus/vendor/bundle/ruby/2.6.0"
# ENV GEM_PATH="/usr/local:/usr/local/bin:/srv/Portus/vendor:/srv/Portus/vendor/bundle:/srv/Portus/vendor/bundle/ruby/2.6.0"
# ENV GEM_PATH="${GEM_PATH}:/srv/Portus/vendor/bundle/ruby/2.6.0"

# ARG GEM_HOME=/srv/Portus/vendor/bundle/ruby/2.6.0
# ENV GEM_HOME=/srv/Portus/vendor/bundle/ruby/2.6.0
# ENV GEM_HOME=/srv/Portus/vendor/bundle


# https://bundler.io/v1.17/bundle_install.html
# ARG BUNDLE_PATH="${BUNDLE_PATH}:/srv/Portus/vendor/bundle"
# ENV BUNDLE_PATH="${BUNDLE_PATH}:/srv/Portus/vendor/bundle"

# ARG BUNDLE_HOME=/srv/Portus/vendor/bundle
# ENV BUNDLE_HOME=/srv/Portus/vendor/bundle


# ARG RAILS_ENV=prod
# ENV RAILS_ENV=prod

# ------------------------------------------
#  Commands that should run identically on
#  Debian, and OPENSUSE
# ------------------------------------------
#  installs dev stack to build portus

ARG RUBYGEMS_VERSION=3.0.3
ENV RUBYGEMS_VERSION=3.0.3


ARG RAILS_VERSION=5.2.3
ENV RAILS_VERSION=5.2.3

ARG BUNDLE_VERSION='1.16.4'
ENV BUNDLE_VERSION='1.16.4'

ARG BUNDLER_VERSION='1.16.4'
ENV BUNDLER_VERSION='1.16.4'


# -- forcing update rubygem to an accurate version
RUN gem update --system ${RUBYGEMS_VERSION}

# RUN rm /usr/local/bin/bundle

RUN gem uninstall bundler
RUN gem uninstall bundle
RUN gem uninstall bundle --install-dir /usr/local/
RUN rm -fr /usr/local/bundle
# --- #
# RUN gem install bundler --no-document -v 1.17.3
RUN gem update
RUN gem install bundler -v "${BUNDLER_VERSION}"
# RUN gem install bundle --no-document -v "${BUNDLER_VERSION}"
RUN gem install bundle
RUN bundle install --retry=3
# RUN bundle update --bundler
# unnecessary in a docker library official ruby image # update-alternatives --install /usr/bin/bundle bundle /usr/bin/bundle.ruby2.6 3 && \
# unnecessary in a docker library official ruby image # update-alternatives --install /usr/bin/bundler bundler /usr/bin/bundler.ruby2.6 3 && \

RUN export PATH=$PATH:/usr/local/go/bin && go get -u github.com/vbatts/git-validation && \
    go get -u github.com/openSUSE/portusctl && \
    mv /root/go/bin/git-validation /usr/local/bin/ && \
    mv /root/go/bin/portusctl /usr/local/bin/

RUN echo "[FINISHED] : Commands that should run identically on Debian and OEPNSUSE"



# --- mandatory future change :
# accurate version of annotate, no context dependent dependency resolution
ARG RUBY_ANNOTATE_VERSION=3.1.0
ENV RUBY_ANNOTATE_VERSION=3.1.0
# RUBY_ANNOTATE_VERSION=2.7.4
# RUN gem i annotate -v $RUBY_ANNOTATE_VERSION
RUN gem i annotate
ARG RUBY_RAKE_VERSION=12.3.2
ENV RUBY_RAKE_VERSION=12.3.2

RUN gem i rake -v $RUBY_RAKE_VERSION

# ---
# Or Ruby ([RVM RubyVersionManager] I believe) is
# going to throw an error
# ---
# https://rvm.io/workflow/projects
RUN ruby --version|awk '{print $2}' > .ruby-version

# ---
# Or Bundler is gonna complain about it missing
# RUN gem i minitest -v 5.11.3

#

#RUN export PATH=$PATH:/usr/local/go/bin && go get gopkg.in/urfave/cli.v1
RUN apt-get update -y && apt-get install -y go-md2man
RUN apt-get install graphviz -y
# RUN export PATH=$PATH:/usr/local/go/bin && make install
# --
# RUN bundler install --deployment && bundler package --all

EXPOSE 3000
ENTRYPOINT ["/init"]


# --------------------------------------------------------------
# --------------------------------------------------------------
# ------ IMPOSSIBLE D INSTALLER PORTUSCTL, ET
# ------ SON BUILD FROM SOURCE BEUG DANS TOUS LES SENS
# --------------------------------------------------------------
# --------------------------------------------------------------
# ------
ARG PUMA_VERSION=4.3.3
ENV PUMA_VERSION=4.3.3

RUN gem i puma -v "${PUMA_VERSION}"

COPY .portusgitignore .
RUN cp ./.portusgitignore ./.gitignore
RUN git init
RUN git add --all && git commit -m "releasing-2.5.0-rc"
RUN git tag 2.5.0 -m "releasing-2.5.0-rc"

RUN bundle --deployment
# ---
# ---
# By default,its the foreground webapp and Docker auth v2 service, not the background.
# ---

ENV PORTUS_BACKGROUND=${PORTUS_BACKGROUND:-''}
# ------
# Pour démarrer portus enmode [portus] :
# [bundler exec "pumactl -F /srv/Portus/config/puma.rb start"]
# [bundler exec "puma -C /srv/Portus/config/puma.rb"]
# [rails server]
# ------------------------------------------
# Pour démarrer portus enmode [background] :
# [bundler exec "rails r /srv/Portus/bin/background.rb"]
#

# Tres interessant : la commande pumactl c'estpastrouvée, je suis donc obligé, de trouvr un moyen d'installer pumactl
# root@747b24cf1854:/srv/Portus# git tag 2.5.0 -m "releasing-2.5.0-rc"
# root@747b24cf1854:/srv/Portus# bundler exec "pumactl -F /srv/Portus/config/puma.rb start"
# [25681] Puma starting in cluster mode...
# [25681] * Version 3.12.1 (ruby 2.6.0-p0), codename: Llamas in Pajamas
# [25681] * Min threads: 1, max threads: 4
# [25681] * Environment: development
# [25681] * Process workers: 4
# [25681] * Preloading application
# [schema] Selected the schema for mysql
# [WARN] couldn't connect to database. Skipping PublicActivity::Activity#parameters's serialization
# No such file or directory - connect(2) for /srv/Portus/tmp/sockets/puma.sock
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/binder.rb:371:in `initialize'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/binder.rb:371:in `new'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/binder.rb:371:in `add_unix_listener'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/binder.rb:141:in `block in parse'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/binder.rb:90:in `each'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/binder.rb:90:in `parse'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/runner.rb:153:in `load_and_bind'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/launcher.rb:186:in `run'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/cli.rb:80:in `run'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/cluster.rb:412:in `run'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/control_cli.rb:261:in `start'
# /usr/local/bundle/gems/puma-3.12.1/lib/puma/control_cli.rb:225:in `run'
# /usr/local/bundle/gems/puma-3.12.1/bin/pumactl:8:in `<top (required)>'
# /usr/local/bundle/bin/pumactl:23:in `load'
# /usr/local/bundle/bin/pumactl:23:in `<main>'
# root@747b24cf1854:/srv/Portus# # git tag 2.5.0 -m "releasing-2.5.0-rc"
# root@747b24cf1854:/srv/Portus# # git add --all && git commit -m "releasing-2.5.0-rc"
# root@747b24cf1854:/srv/Portus# gem install portusctl
# ERROR:  Could not find a valid gem 'portusctl' (>= 0) in any repository
# ERROR:  Possible alternatives: portugal
# root@747b24cf1854:/srv/Portus# ./bin/
# bundle               integration/         rake                 spring
# ci/                  rails                setup                test-integration.sh
# root@747b24cf1854:/srv/Portus# rails server
# => Booting Puma
# => Rails 5.2.3 application starting in development
# => Run `rails server -h` for more startup options
# [schema] Selected the schema for mysql
# [WARN] couldn't connect to database. Skipping PublicActivity::Activity#parameters's serialization
# [25693] Puma starting in cluster mode...
# [25693] * Version 3.12.1 (ruby 2.6.0-p0), codename: Llamas in Pajamas
# [25693] * Min threads: 1, max threads: 4
# [25693] * Environment: development
# [25693] * Process workers: 4
# [25693] * Preloading application
# [25693] * Listening on unix:///srv/Portus/tmp/sockets/puma.sock
# [25693] Use Ctrl-C to stop
# [25693] - Worker 0 (pid: 25703) booted, phase: 0
# [25693] - Worker 1 (pid: 25705) booted, phase: 0
# [25693] - Worker 2 (pid: 25709) booted, phase: 0
# [25693] - Worker 3 (pid: 25717) booted, phase: 0
#







####### environnement exec portus puma
ENV PORTUS_MACHINE_FQDN=${PORTUS_MACHINE_FQDN:-'pegasusio.io'}
ENV PORTUS_PASSWORD=${PORTUS_PASSWORD:-'123123123'}
ENV PORTUS_KEY_PATH=${PORTUS_KEY_PATH:-'/secrets/certificates/portus.key'}
#RACK ENV DOIT ETRE A PRODUCTION POUR QUE CA FONCTIONNE
ENV RACK_ENV=${RACK_ENV:-'production'}
ENV PORTUS_SECRET_KEY_BASE=${PORTUS_SECRET_KEY_BASE:-'lhkjhgjhgjhgjhgjgf638ygjh685'}
ENV CCONFIG_PREFIX=PORTUS

ENV PORTUS_DB_HOST=${PORTUS_DB_HOST:-'db'}
ENV PORTUS_DB_DATABASE=${PORTUS_DB_DATABASE:-'portus_production'}
ENV PORTUS_DB_PASSWORD=${PORTUS_DB_PASSWORD:-'tintin'}
ENV PORTUS_DB_POOL=5
####### instruction de demarrage qui marche
# bundler exec "pumactl -F /srv/Portus/config/puma.rb start"
RUN bundle --deployment
RUN mkdir -p /srv/Portus/tmp/sockets
RUN touch /srv/Portus/tmp/sockets/puma.sock

CMD ["/bin/bash"]
