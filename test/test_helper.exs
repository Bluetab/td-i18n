ExUnit.start()

# Start the repo
Application.ensure_all_started(:td_i18n)
Ecto.Adapters.SQL.Sandbox.mode(TdI18n.Repo, :manual)
