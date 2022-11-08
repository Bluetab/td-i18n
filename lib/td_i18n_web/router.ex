defmodule TdI18nWeb.Router do
  use TdI18nWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TdI18nWeb do
    pipe_through :api

    resources "/locales", LocaleController, except: [:new, :edit] do
      resources "/messages", LocaleMessageController,
        except: [:new, :edit, :update],
        name: "message"
    end

    resources "/messages", MessageController, except: [:new, :create, :edit]
  end
end
