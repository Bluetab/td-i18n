defmodule TdI18n.Repo do
  use Ecto.Repo,
    otp_app: :td_i18n,
    adapter: Ecto.Adapters.Postgres
end
