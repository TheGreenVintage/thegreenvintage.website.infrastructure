#!/bin/bash -l

set -e

GIT_BRANCH=$1

WWW=$HOME/shared/public
GIT_REPO=$HOME/shared/repositories/static
TMP_GIT_CLONE=$HOME/tmp/git/static
PUBLIC_PROD_WWW=$WWW/static
PUBLIC_NEXT_WWW=$WWW/next.static

if [ "$GIT_BRANCH" == "master" ]; then
  JEKYLL_ENV=production
  PUBLIC_WWW=$PUBLIC_PROD_WWW
  DATO_ENV_ID={{ vault_dato_production_id }}
else
  JEKYLL_ENV=development
  PUBLIC_WWW=$PUBLIC_NEXT_WWW
  DATO_ENV_ID={{ vault_dato_staging_id }}
fi

rm -rf "$TMP_GIT_CLONE"
git clone -b "$GIT_BRANCH" "$GIT_REPO" "$TMP_GIT_CLONE"

pushd "$TMP_GIT_CLONE"
  bundle install --path "$HOME/.gem"
  bundle exec dato dump --token="$DATO_API_TOKEN"
  JEKYLL_ENV="$JEKYLL_ENV" bundle exec jekyll build --source "$TMP_GIT_CLONE" --destination "$PUBLIC_WWW"
popd

rm -Rf "$TMP_GIT_CLONE"

# DatoCMS successful build notification
curl -n -X POST "https://webhooks.datocms.com/$DATO_ENV_ID/deploy-results" -H 'Content-Type: application/json' -d '{ "status": "success" }'

exit
