defmodule TdI18n.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TdI18n.Repo,
      TdI18n.Scheduler,
      TdI18nWeb.Endpoint,
      TdI18n.Cache.LocaleCache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TdI18n.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TdI18nWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
