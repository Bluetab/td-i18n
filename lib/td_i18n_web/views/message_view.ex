defmodule TdI18nWeb.MessageView do
  use TdI18nWeb, :view
  alias TdI18nWeb.MessageView

  def render("index.json", %{messages: messages}) do
    %{data: render_many(messages, MessageView, "message.json")}
  end

  def render("show.json", %{message: message}) do
    %{data: render_one(message, MessageView, "message.json")}
  end

  def render("message.json", %{message: message}) do
    Map.take(message, [:id, :definition, :description, :message_id, :locale_id])
  end
end
