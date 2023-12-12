defmodule TdI18nWeb.AllLocaleController do
  use TdI18nWeb, :controller

  alias TdI18n.AllLocales

  def index(conn, _params) do
    render(conn, "index.json", all_locales: AllLocales.list_all_locale())
  end
end
