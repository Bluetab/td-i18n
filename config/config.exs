# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# Environment
config :td_i18n, :env, Mix.env()

# General application configuration
config :td_i18n, ecto_repos: [TdI18n.Repo]
config :td_i18n, TdI18n.Repo, pool_size: 4

# Configures the endpoint
config :td_i18n, TdI18nWeb.Endpoint,
  http: [port: 4003],
  url: [host: "localhost"],
  render_errors: [view: TdI18nWeb.ErrorView, accepts: ~w(json)]

# Configures Auth module Guardian
config :td_i18n, TdI18n.Auth.Guardian,
  allowed_algos: ["HS512"],
  issuer: "tdauth",
  ttl: {1, :hours},
  secret_key: "SuperSecretTruedat"

config :td_i18n, hashing_module: Comeonin.Bcrypt

# Configures Elixir's Logger
# set EX_LOGGER_FORMAT environment variable to override Elixir's Logger format
# (without the 'end of line' character)
# EX_LOGGER_FORMAT='$date $time [$level] $message'
config :logger, :console,
  format:
    (System.get_env("EX_LOGGER_FORMAT") || "$date\T$time\Z [$level]$levelpad $metadata$message") <>
      "\n",
  level: :info,
  metadata: [:pid, :module],
  utc_log: true

config :phoenix, :json_library, Jason

config :td_cache, redis_host: "redis"

config :td_i18n, TdI18n.Scheduler,
  jobs: [
    [
      schedule: "@reboot",
      task: {TdI18n.Locales, :load_from_file!, ["priv/repo/messages.json"]},
      run_strategy: Quantum.RunStrategy.Local
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
