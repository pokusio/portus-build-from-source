# vvv

* Une des paramètres de configuration de `portus`, est `PORTUS_SECRET_KEY_BASE` :
  * C'est un secret (sa valeur doit être accédée de manière contrôlée)
  * Sa valeur doit être générée, et conservée dans un secret manager.
  * Portus est une application Ruby on Rails, et en tant que telle, elle a un paramètre de configuration `secret_key_base`, https://guides.rubyonrails.org/security.html#session-storage .
  * Le paramètre de configuration de Portus,  `PORTUS_SECRET_KEY_BASE`, permet de donner une valeur à son paramètre `secret_key_base` en tant qu'application Ruby On Rails.
  * La valeur de `PORTUS_SECRET_KEY_BASE`, doit donc être générée comme doit l'être celle de `secret_key_base`, c'estàdire, comme décrit dans https://guides.rubyonrails.org/security.html#session-storage , avec :

>
>
> The `CookieStore` uses the encrypted cookie jar to provide a secure, encrypted location to store session data.
> Cookie-based sessions thus provide both integrity as well as confidentiality to their contents.
> The encryption key, as well as the verification key used for signed cookies, is derived from
>  the `secret_key_base` configuration value.
>
> Secrets must be long and random.
> Use `rails secret` to get new unique secrets.
>
>

Et voici donc comment générer cette valeur (cf. [cette documentation](./documentation/security/rails_secret_key_base/README.md) ):

```bash
mkdir -p ~/railsecrecy
cd ~/railsecrecy

# -- #
docker run -itd --restart always --name railsgenerator rails:latest bash

docker exec -it railsjb bash -c "rails --version"

# Ou alors :

# générer le projet en bind local, pour garder le code généré
docker run -it --rm --user "$(id -u):$(id -g)" -v "$PWD":/usr/src/generator -w /usr/src/generator rails rails new --skip-bundle portusecretkeybase

ls -allh $(pwd)/portusecretkeybase/

docker run -it --rm --user root -v "$PWD":/usr/src/generator -w /usr/src/generator rails bash -c "cd portusecretkeybase && gem install rake -v '13.0.1' && bundle install && rails secret"


```
* Mais à partir de là j'ai une erreur hyper chiante quoi :

```bash
jbl@poste-devops-jbl-16gbram:~/railsecretmgmt$ docker run -it --rm --user root -v "$PWD":/usr/src/generator -w /usr/src/generator rails bash -c "cd portusecretkeybase && gem install rake -v '13.0.1' && bundle install && rails secret"Fetching: rake-13.0.1.gem (100%)
Successfully installed rake-13.0.1
1 gem installed
Fetching gem metadata from https://rubygems.org/............
Fetching version metadata from https://rubygems.org/..
Fetching dependency metadata from https://rubygems.org/.
Resolving dependencies...
byebug-11.1.1 requires ruby version >= 2.4.0, which is incompatible with the current version, ruby 2.3.3p222
jbl@poste-devops-jbl-16gbram:~/railsecretmgmt$
```

Alors que je suis les instructions officielles du https://hub.docker.com/_/rails/

Vraiment Ruby-on-Rails c'est relou de chez relou là-dedans.

* Bon je dois builder ma propre image rails basée sur `ruby:2.4` au lieu de `2.3` :

```bash

export DOCKER_BUILD_CONTEXT=$(pwd)/secrets-management/rails_secret_base_key


docker build --build-arg RAILS_VERSION=5.0.1 -t railsecretmngr:0.0.1 $DOCKER_BUILD_CONTEXT

mkdir -p ~/railsecrecy
cd ~/railsecrecy

# -- #
# générer le projet en bind local, pour garder le code généré
docker run -it --rm --user "$(id -u):$(id -g)" -v "$PWD":/usr/src/generator -w /usr/src/generator railsecretmngr:0.0.1 rails new --skip-bundle portusecretkeybase

ls -allh $(pwd)/portusecretkeybase/

docker run -it --rm --user root -v "$PWD":/usr/src/generator -w /usr/src/generator railsecretmngr:0.0.1 bash -c "cd portusecretkeybase && gem install rake -v '13.0.1' && bundle install && rails secret"

docker run -it --rm --user root -v "$PWD":/usr/src/generator -w /usr/src/generator railsecretmngr:0.0.1 bash -c "cd portusecretkeybase && gem install rake -v '13.0.1' && bundle install && rails secret > ./jblsecret.key.base.portus"


```

* Contenu du `./secrets-management/rails_secret_base_key/Dockerfile` (aucun fichier dépendance dans le contexte de build docker):

```Dockerfile
FROM ruby:2.5.0
# FROM ruby:2.4

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update -y && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
# RUN apt-get update -y && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*
# because in debian buster the package name is 'default-mysql-client'
# https://packages.debian.org/search?searchon=names&keywords=mysql-client
RUN apt-get update -y && apt-get install -y default-mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

#

ENV RAILS_VERSION 5.0.1

RUN gem install rails --version "$RAILS_VERSION"

```

### Une amélioration à apporter

Avec cette petite recette pour utiliser `rails secret`, avant d'avoir fait la provision de portus, j'ai un défaut :

* À chaque fois que je veux ré-générer une `secret_key_base`, je dois refaire tout le build de l'application ruby générée.
* Cela rend inutilement long quelquechose qui devraitêtre hyper rapide.
* Je dois le faire évoluerqpourque l'on ait pas besoin de faire le `bundle install` à chaque foisque l'on veut générerune `secret_key_base`.


# OPERATION STANDARD DEFINIE COMPLEMTENT

Ok, jesais ce qu'ilfaut faire :
* il faut rajouter mon conteneur `rails_secret_base_key_generator` dans le docker compose,
* ce petit conte

# Même travail pour le paramètre `SECRET_PORTUS_API_KEY_JINJA2_VAR` du `registry`

`SECRET_PORTUS_API_KEY` est une variable d'environement de cette recette, permettant
de donner une valeur au paramètre de configuration `secret`, dans le fichier `./registry/config.yml` :

```Yaml
notifications:
  endpoints:
    - name: portus
      url: https://PORTUS_SERVICE_FQDN_JINJA2_VAR:3000/v2/webhooks/events
      # headers:
        # Authorization: Bearer bs2M5RmbspjzLkh4GrXX
      timeout: 500ms
      threshold: 5
      backoff: 1s
  secret: SECRET_PORTUS_API_KEY_JINJA2_VAR
```

Cf. https://docs.docker.com/registry/notifications/

Ce secret doit être un token d'authentification valide pour le
endpoint portus `https://${PORTUS_SERVICE_FQDN}:3000/v2/webhooks/events`

Je ne comprends pas encore comment la valeur fixe que je laisse toujours pour ce paramètre, fonctionne.


# Une solution trouvée sur github à comparer

Ah, sur le sujet de la rotation de ce secret, j'ai : https://github.com/envato/rails_session_key_rotator

Je n'ai pas encore compris son fonctionnement, mais on dirait qu'il est basé sur l'exécution de tâches de build des développeurs, ...

Déterminer comment fonctionne ce composant

Je pense quand même que c'est une solution utilisable en mode dev / build from source



# Docs references

The portus Documentation says almost nothing about that :
* It talks about `PORTUS_SECRET_KEY_BASE` here http://port.us.org/docs/deploy.html#docker but just tells you go and read https://guides.rubyonrails.org/security.html  (general rails security guide ...)
* It also talks about this env. variable, here : http://port.us.org/docs/secrets.html   to tell you how to not put that secret value inside an env. variable, but inside a file instead, (and the container reads the file to get the secret) . But that part won't explain you at all, what that _`secret_base_key`_ thing is.

# Good to know

This signing cookies, especially session cookies, is a security measure enhanced by rails to reach compliance to OWASP security standards (which is quite a good,widely known security standard)

I think the exact mechanism implemented in rails with the _secret base key_, is the following : https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/JSON_Web_Token_Cheat_Sheet_for_Java.md#token-sidejacking


I the rails security guide mentioned in the `portus` documentation, go to   https://guides.rubyonrails.org/security.html#session-storage , and search `Ctrl + F` the string `secret_key_base` in that paragraph, you will find the same info I used to do all this.

# Last word

Problem here, as you'll find out, is that there is today in `February 2020`, no `rails:$WHATEVER_VERSION_YOU_CHOOSE` container image is based on a version of ruby above `ruby:2.3`  on docker hub.

So I had to build my own, so I can then install the right version of ruby (or executing the command `rails secret`, `rails` will throw an error complaining about the ruby version not being above `2.4/2.5`),  and finally generate a _secret base key_ .


You're welcome ;)
