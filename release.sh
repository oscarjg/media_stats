#!/usr/bin/env bash

ENV=${1:-"prod"}

if [ {ENV} = prod ]; then
    mix deps.get --only prod
else
    mix deps.get
fi

MIX_ENV=${ENV} mix compile &&
npm run deploy --prefix ./apps/media_stats_web/assets &&
MIX_ENV=${ENV} mix do phx.digest, distillery.release --env=${ENV}