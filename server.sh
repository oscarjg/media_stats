#!/usr/bin/env bash

ACTION=${1:-"describe"}
USER=${2:-"root"}
HOST=${3:-"148.251.47.102"}
PORT=${4:-"22"}

ssh ${USER}@${HOST} -p ${PORT} /var/www/media_stats/bin/media_stats_umbrella ${ACTION}