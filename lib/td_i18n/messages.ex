defmodule TdI18n.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query

  require Logger

  alias Ecto.Multi
  alias TdI18n.Locales
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

  defp insert_multi_message(multi, {lang_id, params}, message_id) do
    case Locales.get_locale(lang_id) do
      %{id: locale_id} ->
        params = Map.put(params, "message_id", message_id)
        changeset = Message.changeset(%Message{locale_id: locale_id}, params)

        Multi.insert(multi, locale_id, changeset)

      _ ->
        Multi.error(multi, :error, :not_found)
    end
  end

  defp map_multi_result({:ok, result}) do
    result
    |> Enum.map(fn {_lang_id, message} -> message end)
    |> then(&{:ok, &1})
  end

  defp map_multi_result({:error, _, error, _}), do: {:error, error}

  def create_messages(message_id, langs) do
    langs
    |> Enum.reduce(Multi.new(), fn lang, multi ->
      insert_multi_message(multi, lang, message_id)
    end)
    |> Repo.transaction()
    |> then(&map_multi_result/1)
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
