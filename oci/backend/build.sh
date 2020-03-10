#!/bin/bash

# ---
# Zero documentation about building portus from source as a rails application.
# So I do that myself,using :
# -> https://www.digitalocean.com/community/tutorials/how-to-build-a-ruby-on-rails-application
# ---
#
echo "This script will build portus backend"
echo "It is not implemented yet"
exit 1
export VAULT_TOKEN_FILE=${VAULT_TOKEN_FILE:-'/secrets/vault/token'}
if [ -f $VAULT_TOKEN_FILE ]; then
  export $VAULT_TOKEN=$(cat $VAULT_TOKEN_FILE)
else
  echo " [$VAULT_TOKEN_FILE] HashiCorp Vault's credentials are missing, can't workwith Vault."
fi;



# defaults to 'portus.generated.secret.key.base'
export PORTUS_SECRET_KEY_BASE_FILE_NAME=${PORTUS_SECRET_KEY_BASE_FILE_NAME:-'portus.generated.secret.key.base'}
rails secret > $(pwd)/$PORTUS_SECRET_KEY_BASE_FILE_NAME

echo "$(pwd)/$PORTUS_SECRET_KEY_BASE_FILE_NAME"
ls -allh $PORTUS_SECRET_KEY_BASE_FILE_NAME
cat $(pwd)/$PORTUS_SECRET_KEY_BASE_FILE_NAME

cp $(pwd)/$PORTUS_SECRET_KEY_BASE_FILE_NAME /usr/src/portusecretkeybase/share

ls -allh /usr/src/portusecretkeybase/share

# ---
# we'll have to store to hashicorp vault, disabling
# that until vault is integrated into infrastructure
exit 0
echo "Now will store that secret into HashiCorp Vaultin a KV engine dedicated for the infrastructure"


# --
# We need : [curl], and [jq]
# --
# Following exact steps described at
# https://learn.hashicorp.com/vault/secrets-management/sm-versioned-kv#api-call-using-curl
# --
#
# -- --- -- #
# -- 1./ -- #
# -- --- -- #
# We first need to make sure we are
# running a KV engine version 2 (not version 1)
#


# --
# To check the KV v2 secrets engine at secret/ path version option:
curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDRESS/v1/sys/mounts > ./CHECK_VAULT_KV_VERSION.json
cat ./CHECK_VAULT_KV_VERSION.json | jq '.["secret/"]'
export CHECK_VAULT_KV_VERSION=$(cat ./CHECK_VAULT_KV_VERSION.json | jq '.["secret/"].options.version'| awk -F '"' '{print $2}')



# ---
# Example sample responsefromhashicorpvault, where we will be searchingfor version option of kv secret engine :
# ---
#   "secret/": {
#     "accessor": "kv_f05b8b9c",
#     "config": {
#       "default_lease_ttl": 0,
#       "force_no_cache": false,
#       "max_lease_ttl": 0,
#       "plugin_name": ""
#     },
#     "description": "key/value secret storage",
#     "local": false,
#     "options": {
#       "version": "2"
#     },
#     "seal_wrap": false,
#     "type": "kv"
#   },
# ---

# --
# If the version is 1, upgrade it to v2 by invoking the sys/mounts/secret/tune endpoint.
tee upgrade-kv-payload.json <<"EOF"
{
  "options": {
      "version": "2"
  }
}
EOF



if [ "$CHECK_VAULT_KV_VERSION" == "1" ]; then
  echo "KV Engine [${VAULT_KV_ENGINE}] version option is [1], now upgrading to version [2] "
  curl --header "X-Vault-Token: $VAULT_TOKEN" \
       --request POST \
       --data @upgrade-kv-payload.json \
       $VAULT_ADDRESS/v1/sys/mounts/${VAULT_KV_ENGINE}/tune
       # $VAULT_ADDRESS/v1/sys/mounts/secret/tune
  retval=$?
  if [[ $retval -eq 0 ]]; then
    # After we save the password to vault, update it on the instance
    echo "Successfully saved upgraded KV Engine [${VAULT_KV_ENGINE}] to version option 2 on Vault at [$VAULT_ADDR]"
  else
    echo "Error upgrading KV engine to version 2 on Vault at [$VAULT_ADDR]"
    exit 1
  fi
else
  echo "KV Engine [${VAULT_KV_ENGINE}] version option is already in version 2, now upgrading needed."
fi;

echo "The KV v2 secrets engine at [${VAULT_KV_ENGINE}] path must be enabled : "
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{ "type": "kv-v2" }' \
     $VAULT_ADDR/v1/sys/mounts/${VAULT_KV_ENGINE} | jq .
#      $VAULT_ADDR/v1/sys/mounts/secret | jq .



# -- --- -- #
# -- 2./ -- #
# -- --- -- #
# We write our secret key base  to the
# hashicorp KV Secret engine
#



tee write-secret-payload.json <<EOF
{
  "$VAULT_KV_ENGINE_SECRET_KEY": "$(cat ./$PORTUS_SECRET_KEY_BASE_FILE_NAME)"
}
EOF

# curl --header "X-Vault-Token: $VAULT_TOKEN" \
#       --request POST \
#       --data @write-secret-payload.json \
#       $VAULT_ADDR/v1/secret/data/customer/acme
#

curl --header "X-Vault-Token: $VAULT_TOKEN" \
      --request POST \
      --data @write-secret-payload.json \
      ${VAULT_ADDR}/v1/${VAULT_KV_ENGINE}/${VAULT_KV_ENGINE_SECRET_PATH}
retval=$?
if [[ $retval -eq 0 ]]; then
  # After we save the password to vault, update it on the instance
  echo "Successfully saved renewed [\$PORTUS_SECRET_KEY_BASE] in the [$VAULT_KV_ENGINE] HashiCorp Vault KV Engineas a new version of the [${VAULT_KV_ENGINE_SECRET_PATH} $VAULT_KV_ENGINE_SECRET_KEY] secret."
else
  echo "Error saving renewed [\$PORTUS_SECRET_KEY_BASE] in the [$VAULT_KV_ENGINE] HashiCorp Vault KV Engineas a new version of the [${VAULT_KV_ENGINE_SECRET_PATH} $VAULT_KV_ENGINE_SECRET_KEY] secret."
  exit 1
fi















# Won't use vault as client, will use VAult API instead, with just curl
# vault kv put $VAULT_KV_ENGINE_SECRET_PATH $VAULT_KV_ENGINE_SECRET_KEY=$NEWGENERATEDPASS
