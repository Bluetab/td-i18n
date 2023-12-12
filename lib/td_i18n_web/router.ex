defmodule TdI18nWeb.Router do
  use TdI18nWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug TdI18n.Auth.Pipeline.Secure
  end

  scope "/api", TdI18nWeb do
    pipe_through [:api, :api_auth]

    get "/locales/all_locales", AllLocaleController, :index

    resources "/locales", LocaleController, only: [:create, :update, :delete] do
      resources "/messages", LocaleMessageController,
        only: [:create],
        name: "message"
    end

    resources "/messages", MessageController, only: [:update, :delete, :index, :show, :create]
  end

  scope "/api", TdI18nWeb do
    pipe_through :api

    get "/ping", PingController, :ping

    resources "/locales", LocaleController, only: [:index, :show] do
      resources "/messages", LocaleMessageController,
        only: [:index],
        name: "message"
    end
  end
end
