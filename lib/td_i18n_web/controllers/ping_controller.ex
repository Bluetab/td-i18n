defmodule TdI18nWeb.PingController do
  use TdI18nWeb, :controller

  action_fallback TdI18nWeb.FallbackController

  def ping(conn, _params) do
    send_resp(conn, :ok, "pong")
  end
end
