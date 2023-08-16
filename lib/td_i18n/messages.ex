defmodule TdI18n.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query

  require Logger

  alias Ecto.Multi
  alias TdCache.I18nCache
  alias TdI18n.Locales
  alias TdI18n.Locales.Locale
  alias TdI18n.Messages.Message
  alias TdI18n.Repo

  def list_messages do
    Repo.all(Message)
  end

  def get_message!(id), do: Message |> Repo.get!(id) |> Repo.preload(:locale)

  def create_message(%Locale{id: locale_id, lang: lang}, %{} = params) do
    changeset = Message.changeset(%Message{locale_id: locale_id}, params)

    Multi.new()
    |> Multi.insert(:message, changeset)
    |> Multi.run(:cache, fn _, %{message: message} -> I18nCache.put(lang, message) end)
    |> Repo.transaction()
    |> then(&multi_result(&1))
  end

  defp insert_multi_message(multi, {lang_id, params}, message_id) do
    case Locales.get_locale(lang_id) do
      %{id: locale_id, lang: lang} ->
        params = Map.put(params, "message_id", message_id)

        changeset = Message.changeset(%Message{locale_id: locale_id}, params)

        cache_multi_id = String.to_atom("cache_#{locale_id}")

        multi
        |> Multi.insert(locale_id, changeset)
        |> Multi.run(cache_multi_id, fn _, %{^locale_id => message} ->
          I18nCache.put(lang, message)
        end)

      _ ->
        Multi.error(multi, :error, :not_found)
    end
  end

  def create_messages(message_id, langs) do
    langs
    |> Enum.reduce(Multi.new(), fn lang, multi ->
      insert_multi_message(multi, lang, message_id)
    end)
    |> Repo.transaction()
    |> then(&map_multi_result/1)
  end

  def update_message(%Message{} = message, params) do
    changeset = Message.changeset(message, params)

    Multi.new()
    |> Multi.update(:message, changeset)
    |> Multi.run(:cache, fn _, %{message: %{locale: %{lang: lang}} = message} ->
      I18nCache.put(lang, message)
    end)
    |> Repo.transaction()
    |> then(&multi_result(&1))
  end

  def delete_message(%Message{} = message) do
    Multi.new()
    |> Multi.delete(:message, message)
    |> Multi.run(:cache, fn _, %{message: %{message_id: message_id, locale: %{lang: lang}}} ->
      I18nCache.delete(lang, message_id)
    end)
    |> Repo.transaction()
    |> then(&multi_result(&1))
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

  defp map_multi_result({:ok, result}) do
    result
    |> Enum.reduce(
      [],
      fn
        {_lang_id, message}, acc when is_map(message) -> [message | acc]
        {_cache_id, [_ | _]}, acc -> acc
      end
    )
    |> Enum.reverse()
    |> then(&{:ok, &1})
  end

  defp map_multi_result({:error, _, error, _}), do: {:error, error}

  defp multi_result({:ok, %{message: changeset}}), do: {:ok, changeset}

  defp multi_result({:error, _, error, _}), do: {:error, error}
end
