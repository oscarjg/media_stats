#!/usr/bin/env bash

VERSION=${1}
ACTION=${2:-"upgrade"}
ENV=${3:-prod}
DEPLOY_PATH=${4:-"/var/www/media_stats"}
BRANCH=${5:-"master"}

echo "Updating repository from branch $BRANCH"
git fetch
git checkout ${BRANCH}
git pull origin ${BRANCH}

echo "Fetching deps"
if [ ${ENV} = prod ]; then
    mix deps.get --only prod
else
    mix deps.get
fi

MIX_ENV=${ENV} mix compile
npm install --prefix ./apps/media_stats_web/assets && npm run deploy --prefix ./apps/media_stats_web/assets

if [ ${ACTION} = upgrade ]; then
    echo "MIX_ENV=${ENV} mix do phx.digest, distillery.release --env=${ENV} --upgrade"
    MIX_ENV=${ENV} mix do phx.digest, distillery.release --env=${ENV} --upgrade
else
    echo "MIX_ENV=${ENV} mix do phx.digest, distillery.release --env=${ENV}"
    MIX_ENV=${ENV} mix do phx.digest, distillery.release --env=${ENV}
fi

echo "Extracting release"

if [ ! -d ${DEPLOY_PATH} ]; then
    echo "Creating release folder"
    mkdir ${DEPLOY_PATH}
else
    echo "Release folder ${DEPLOY_PATH} has already exists"
fi

if [ ${ACTION} = upgrade ]; then
    mkdir ${DEPLOY_PATH}/releases/${VERSION}
    cp _build/${ENV}/rel/media_stats_umbrella/releases/${VERSION}/media_stats_umbrella.tar.gz ${DEPLOY_PATH}/releases/${VERSION}/
    echo "The app is ready for upgrading running ---> ${DEPLOY_PATH}/bin/media_stats_umbrella upgrade ${VERSION}"
else
    cp _build/${ENV}/rel/media_stats_umbrella/releases/${VERSION}/media_stats_umbrella.tar.gz ${DEPLOY_PATH}
    cd ${DEPLOY_PATH}
    tar xf media_stats_umbrella.tar.gz
    echo "The app is ready for running ---> PORT=4000 ${DEPLOY_PATH}/bin/media_stats_umbrella start"
fi