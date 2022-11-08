defmodule TdI18nWeb.MessageController do
  use TdI18nWeb, :controller

  alias TdI18n.Messages
  alias TdI18n.Messages.Message

  action_fallback TdI18nWeb.FallbackController

  def index(conn, _params) do
    messages = Messages.list_messages()
    render(conn, "index.json", messages: messages)
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
