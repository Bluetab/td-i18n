defmodule TdI18n.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query

  require Logger

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

  def delete_deprecated_messages(message_ids, definitions) do
    Message
    |> where([m], m.message_id in ^message_ids)
    |> or_where([m], m.definition in ^definitions)
    |> Repo.delete_all()
    |> maybe_log()
  end

  defp maybe_log({n, _}) when is_integer(n) and n > 0 do
    Logger.info("Deleted #{n} deprecated messages")
  end

  defp maybe_log(_), do: :ok
end
