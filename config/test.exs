use Mix.Config

config :ballistic, Ballistic.Repo,
  pool: Ecto.Adapters.SQL.Sandbox

import_config "#{Mix.env}.secret.exs"