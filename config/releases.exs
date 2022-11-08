import Config

# Configure your database
config :td_i18n, TdI18n.Repo,
  username: System.fetch_env!("DB_USER"),
  password: System.fetch_env!("DB_PASSWORD"),
  database: System.fetch_env!("DB_NAME"),
  hostname: System.fetch_env!("DB_HOST"),
  port: System.get_env("DB_PORT", "5432") |> String.to_integer(),
  pool_size: System.get_env("DB_POOL_SIZE", "4") |> String.to_integer()

# config :td_i18n, TdI18n.Auth.Guardian, secret_key: System.fetch_env!("GUARDIAN_SECRET_KEY")
