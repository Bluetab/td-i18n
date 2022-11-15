defmodule TdI18nWeb.Router do
  use TdI18nWeb, :router

  pipeline :api do
    plug TdI18n.Auth.Pipeline.Unsecure
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug TdI18n.Auth.Pipeline.Secure
  end

  scope "/api", TdI18nWeb do
    pipe_through :api

    get "/ping", PingController, :ping

    resources "/locales", LocaleController, only: [:index, :show]
  end

  scope "/api", TdI18nWeb do
    pipe_through [:api, :api_auth]

    resources "/locales", LocaleController, only: [:create, :update, :delete] do
      resources "/messages", LocaleMessageController,
        only: [:create],
        name: "message"
    end

    resources "/messages", MessageController, only: [:update, :delete, :index, :show]
  end
end
