defmodule TdI18nWeb.LocaleMessageView do
  use TdI18nWeb, :view

  alias TdI18nWeb.MessageView

  def render("show.json", %{messages: messages}) do
    %{data: render_many(messages, MessageView, "message.json")}
  end
end
