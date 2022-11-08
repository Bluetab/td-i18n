defmodule TdI18nWeb.LocaleMessageController do
  use TdI18nWeb, :controller

  alias TdI18n.Locales
  alias TdI18n.Messages
  alias TdI18n.Messages.Message
  alias TdI18nWeb.MessageView

  action_fallback TdI18nWeb.FallbackController

  def index(conn, _params) do
    messages = Messages.list_messages()
    render(conn, "index.json", messages: messages)
  end

  def create(conn, %{"locale_id" => id, "message" => message_params}) do
    locale = Locales.get_locale!(id)

    with {:ok, %Message{} = message} <- Messages.create_message(locale, message_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.message_path(conn, :show, message))
      |> put_view(MessageView)
      |> render("show.json", message: message)
    end
  end

  def show(conn, %{"id" => id}) do
    message = Messages.get_message!(id)
    render(conn, "show.json", message: message)
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Messages.get_message!(id)

    with {:ok, %Message{} = message} <- Messages.update_message(message, message_params) do
      render(conn, "show.json", message: message)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Messages.get_message!(id)

    with {:ok, %Message{}} <- Messages.delete_message(message) do
      send_resp(conn, :no_content, "")
    end
  end
end
