defmodule TdI18nWeb.LocaleMessageView do
  use TdI18nWeb, :view

  def render("index.json", %{messages: messages}) do
    Map.new(messages, fn %{message_id: id, definition: definition} -> {id, definition} end)
  end
end
