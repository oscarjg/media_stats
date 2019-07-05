use Mix.Config

config :logger, level: :warn

# Media stats
config :media_stats, MediaStats.Repo,
  database: "media_stats_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Media stats Web
config :media_stats_web, MediaStatsWeb.Endpoint,
       http: [port: 4002],
       url: [host: "localhost"],
       server: false

# Password hashing
config :pbkdf2_elixir, :rounds, 1