#!/usr/bin/env bash

VERSION=${1}
ACTION=${2:-"upgrade"}
USER=${3:-"root"}
HOST=${4:-"148.251.47.102"}
PORT=${5:-"22"}

ssh ${USER}@{HOST} -p ${PORT} "shopt -s dotglob && rm -rf /home/bab/media_stats/build/* && shopt -u dotglob"
rsync -r --exclude=".git" --exclude="_build" --exclude="deps" --exclude="*.secret.exs" --exclude=".env" --exclude="node_modules" * ${USER}@${HOST}:${PORT}/home/bab/media_stats/build
ssh ${USER@{HOST} "cd /home/bab/media_stats/build/ && sh deploy.sh ${VERSION} ${ACTION}"