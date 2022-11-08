defmodule TdI18n.Messages do
  @moduledoc """
  The Messages context.
  """

  alias TdI18n.Locales.Locale
  alias TdI18n.Messages.Message
  alias TdI18n.Repo

  def list_messages do
    Repo.all(Message)
  end

  def get_message!(id), do: Repo.get!(Message, id)

  def create_message(%Locale{id: locale_id}, %{} = params) do
    %Message{locale_id: locale_id}
    |> Message.changeset(params)
    |> Repo.insert()
  end

  def update_message(%Message{} = message, params) do
    message
    |> Message.changeset(params)
    |> Repo.update()
  end

  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end
end
