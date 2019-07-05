defmodule MediaStats.Repo do
  use Ecto.Repo,
    otp_app: :media_stats,
    adapter: Ecto.Adapters.Postgres
end
