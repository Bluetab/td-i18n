import Config

# Configure your database
config :td_i18n, TdI18n.Repo,
  username: System.fetch_env!("DB_USER"),
  password: System.fetch_env!("DB_PASSWORD"),
  database: System.fetch_env!("DB_NAME"),
  hostname: System.fetch_env!("DB_HOST"),
  port: System.get_env("DB_PORT", "5432") |> String.to_integer(),
  pool_size: System.get_env("DB_POOL_SIZE", "4") |> String.to_integer(),
  timeout: System.get_env("DB_TIMEOUT_MILLIS", "15000") |> String.to_integer(),
  ssl: System.get_env("DB_SSL", "") |> String.downcase() == "true",
  ssl_opts: [
    cacertfile: System.get_env("DB_SSL_CACERTFILE", ""),
    verify: :verify_peer,
    fail_if_no_peer_cert: System.get_env("DB_SSL", "") |> String.downcase() == "true",
    server_name_indication: System.get_env("DB_HOST") |> to_charlist(),
    versions: [
      System.get_env("DB_SSL_VERSION", "tlsv1.2") |> String.downcase() |> String.to_atom()
    ]
  ]

config :td_i18n, TdI18n.Auth.Guardian, secret_key: System.fetch_env!("GUARDIAN_SECRET_KEY")

config :td_cache,
  redis_host: System.fetch_env!("REDIS_HOST"),
  port: System.get_env("REDIS_PORT", "6379") |> String.to_integer(),
  password: System.get_env("REDIS_PASSWORD")
