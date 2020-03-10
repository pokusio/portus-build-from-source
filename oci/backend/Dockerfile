FROM ruby:2.5.0
# FROM ruby:2.4

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update -y && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
# RUN apt-get update -y && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*
# because in debian buster the package name is 'default-mysql-client'
# https://packages.debian.org/search?searchon=names&keywords=mysql-client
RUN apt-get update -y && apt-get install -y default-mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Dependencies of [/portus/dev/workspace/generate_secret_key_base.sh]
RUN apt-get update -y && apt-get install -y jq git git-flow

#
ARG RUBY_VERSION=2.5.0
ENV RUBY_VERSION=2.5.0

ARG RAILS_VERSION=5.0.1
ENV RAILS_VERSION 5.0.1

ARG RAKE_VERSION=5.0.1
ENV RAKE_VERSION 5.0.1


# PORTUS HTTP URI TO PORTUS SOURCE CODE FOR ANONYMOUS ACCESS
ARG HTTP_URI_TO_PORTUS_PUBLIC_GIT_REPO=$HTTP_URI_TO_PORTUS_PUBLIC_GIT_REPO
# ENV HTTP_URI_TO_PORTUS_PUBLIC_GIT_REPO=$HTTP_URI_TO_PORTUS_PUBLIC_GIT_REPO
# PORTUS SOURCE CODE VERSION
ARG PORTUS_SOURCE_CODE_VERSION=$PORTUS_SOURCE_CODE_VERSION


# ------------------------
# ------------------------
# NOW RUN THE BUILD
# ------------------------
# ------------------------
RUN gem install rails --version "$RAILS_VERSION"

# folder used to do the generation work
RUN mkdir -p /portus/dev/workspace

# folder used to share the generation work
# RUN mkdir -p /portus/dev/share
# VOLUME /portus/dev/share

#
# ICI IL FAUT RECUPERER LE LIVRABLE PORTUS AU LIEU DE FAIRE UN NOUVEAU PROJET PORTUS.
# RUN rails new --skip-bundle /portus/dev/workspace
RUN echo "HTTP_URI_TO_PORTUS_PUBLIC_GIT_REPO=[$HTTP_URI_TO_PORTUS_PUBLIC_GIT_REPO]"
RUN echo "{HTTP_URI_TO_PORTUS_PUBLIC_GIT_REPO}=[${HTTP_URI_TO_PORTUS_PUBLIC_GIT_REPO}]"

RUN git clone $HTTP_URI_TO_PORTUS_PUBLIC_GIT_REPO /portus/dev/workspace


RUN cd /portus/dev/workspace && git checkout $PORTUS_SOURCE_CODE_VERSION
COPY build.sh /portus/dev/workspace/
RUN chmod +x /portus/dev/workspace/build.sh
RUN cd /portus/dev/workspace && echo "ensuite dans [$(pwd)] "
RUN pwd && ls -allh /portus/dev/workspace
WORKDIR /portus/dev/workspace
USER root
RUN gem install rake -v '13.0.1'
RUN pwd && ls -allh .
RUN bundle install

ENTRYPOINT ["/portus/dev/workspace/build.sh"]
CMD ["/bin/bash"]
# CMD ["/usr/local/bundle/bin/rails", "secret"]
# CMD ["/portus/dev/workspace/generate_secret_key_base.sh"]
