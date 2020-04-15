import Config

config :twitter_core,
  ecto_repos: [Twitter.Core.Repo]

config :twitter_core, Twitter.Core.Repo,
  database: "twitter_core_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
