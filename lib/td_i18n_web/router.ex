defmodule TdI18nWeb.Router do
  use TdI18nWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TdI18nWeb do
    pipe_through :api
  end
end
