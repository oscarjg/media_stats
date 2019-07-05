# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, as
# configuration and dependencies are shared in an umbrella
# project. While one could configure all applications here,
# we prefer to keep the configuration of each individual
# child application in their own app, but all other
# dependencies, regardless if they belong to one or multiple
# apps, should be configured in the umbrella to avoid confusion.
import_config "../apps/*/config/config.exs"

# Sample configuration (overrides the imported configuration above):
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

config :media_stats,
       ecto_repos: [MediaStats.Repo]

config :media_stats_web,
       ecto_repos: [MediaStats.Repo],
       generators: [context_app: :media_stats]

config :media_stats_web, MediaStatsWeb.Endpoint,
       url: [host: "localhost"],
       secret_key_base: "uBu9Ad9WWQU5BbQ5pccHymxgG98ZeLJBeQmnUiUIWLAYA1tccwS+QcfkbMzzt7sI",
       render_errors: [view: MediaStatsWeb.ErrorView, accepts: ~w(html json)],
       pubsub: [name: MediaStatsWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
       format: "$time $metadata[$level] $message\n",
       metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"