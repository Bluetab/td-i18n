defmodule TdI18nWeb.LocaleController do
  use TdI18nWeb, :controller

  alias TdI18n.Locales
  alias TdI18n.Locales.Locale

  action_fallback TdI18nWeb.FallbackController

  def index(conn, params) do
    locales =
      params
      |> maybe_add_preloads()
      |> Locales.list_locales()

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

  def create(conn, %{"locales" => locales_params}) do
    with :ok <- authorize(conn),
         {:ok, locales} <- Locales.create_locales(locales_params) do
      conn
      |> put_status(:created)
      |> render("index.json", locales: locales)
    end
  end

  def update(conn, %{"id" => id, "locale" => locale_params}) do
    locale = Locales.get_locale!(id)

    with :ok <- authorize(conn),
         {:ok, %Locale{} = locale} <- Locales.update_locale(locale, locale_params) do
      render(conn, "show.json", locale: locale)
    end
  end

  def delete(conn, _) do
    send_resp(conn, :method_not_allowed, "")
  end

  defp maybe_add_preloads(%{"includeMessages" => includeMessages}) do
    maybe_add_preloads(String.to_atom(includeMessages))
  end

  defp maybe_add_preloads(false), do: []
  defp maybe_add_preloads(_), do: [preload: :messages]
end
