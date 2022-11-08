defmodule TdI18nWeb.LocaleView do
  use TdI18nWeb, :view
  alias TdI18nWeb.LocaleView

  def render("index.json", %{locales: locales}) do
    %{data: render_many(locales, LocaleView, "locale.json")}
  end

  def render("show.json", %{locale: locale}) do
    %{data: render_one(locale, LocaleView, "locale.json")}
  end

  def render("locale.json", %{locale: locale}) do
    %{
      id: locale.id,
      lang: locale.lang,
      is_default: locale.is_default
    }
  end
end
