defmodule TdI18nWeb.LocaleMessageController do
  use TdI18nWeb, :controller

  alias TdI18n.Locales
  alias TdI18n.Messages
  alias TdI18n.Messages.Message
  alias TdI18nWeb.MessageView

  action_fallback TdI18nWeb.FallbackController

  def index(conn, %{"locale_id" => id_or_lang}) do
    %{messages: messages} = get_locale!(id_or_lang)

    render(conn, "index.json", messages: messages)
  end

  def create(conn, %{"locale_id" => id_or_lang, "message" => message_params}) do
    locale = get_locale!(id_or_lang)

    with {:ok, %Message{} = message} <- Messages.create_message(locale, message_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.message_path(conn, :show, message))
      |> put_view(MessageView)
      |> render("show.json", message: message)
    end
  end

  defp get_locale!(id_or_lang) do
    case Integer.parse(id_or_lang) do
      {id, ""} -> Locales.get_locale!(id)
      _ -> Locales.get_by!(lang: id_or_lang)
    end
  end
end
