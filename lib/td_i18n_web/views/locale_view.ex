defmodule TdI18nWeb.LocaleView do
  use TdI18nWeb, :view

  alias TdI18nWeb.MessageView

  def render("index.json", %{locales: locales}) do
    %{data: render_many(locales, __MODULE__, "locale.json")}
  end

  def render("show.json", %{locale: locale}) do
    %{data: render_one(locale, __MODULE__, "locale.json")}
  end

  def render("locale.json", %{locale: %{messages: messages} = locale}) when is_list(messages) do
    messages = render_many(messages, MessageView, "message.json")

    locale
    |> Map.take([:id, :lang, :is_required, :is_default])
    |> Map.put(:messages, messages)
  end

  def render("locale.json", %{locale: locale}) do
    Map.take(locale, [:id, :lang, :is_required, :is_default])
  end
end
