defmodule Twitter.Core.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Twitter.Core.Repo,
      Twitter.Core.ProcessRegistry,
      %{
        id: Phoenix.PubSub.PG2,
        start: {Phoenix.PubSub.PG2, :start_link, [:twitter, []]}
      },
      Twitter.Core.TweetLogSupervisor,
      Twitter.Core.AccountsSupervisor
      # Starts a worker by calling: Twitter.Core.Worker.start_link(arg)
      # {Twitter.Core.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options

    opts = [strategy: :one_for_one, name: Twitter.Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
