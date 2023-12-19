defmodule TdI18nWeb.AllLocaleView do
  use TdI18nWeb, :view

  def render("index.json", %{all_locales: all_locales}) do
    %{data: render_many(all_locales, __MODULE__, "all_locale.json")}
  end

  def render("all_locale.json", %{all_locale: all_locale}) do
    Map.take(all_locale, [:code, :name, :local])
  end
end
