defmodule Twitter.Core.Repo do
  use Ecto.Repo,
    otp_app: :twitter_core,
    adapter: Ecto.Adapters.Postgres
end
