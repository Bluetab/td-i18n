defmodule TdI18nWeb.LocaleController do
  use TdI18nWeb, :controller

  alias TdI18n.Locales
  alias TdI18n.Locales.Locale

  action_fallback TdI18nWeb.FallbackController

  def index(conn, _params) do
    locales = Locales.list_locales()
    render(conn, "index.json", locales: locales)
  end

  def show(conn, %{"id" => id}) do
    locale = Locales.get_locale!(id)
    render(conn, "show.json", locale: locale)
  end

  def create(conn, %{"locale" => locale_params}) do
    with :ok <- authorize(conn),
         {:ok, %Locale{} = locale} <- Locales.create_locale(locale_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.locale_path(conn, :show, locale))
      |> render("show.json", locale: locale)
    end
  end

  def update(conn, %{"id" => id, "locale" => locale_params}) do
    locale = Locales.get_locale!(id)

    with :ok <- authorize(conn),
         {:ok, %Locale{} = locale} <- Locales.update_locale(locale, locale_params) do
      render(conn, "show.json", locale: locale)
    end
  end

  def delete(conn, %{"id" => id}) do
    locale = Locales.get_locale!(id)

    with :ok <- authorize(conn),
         {:ok, %Locale{}} <- Locales.delete_locale(locale) do
      send_resp(conn, :no_content, "")
    end
  end
end
