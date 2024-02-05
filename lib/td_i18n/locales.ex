defmodule TdI18n.Locales do
  @moduledoc """
  The Locales context.
  """

  import Ecto.Query

  alias Ecto.Multi
  alias TdCache.I18nCache
  alias TdI18n.Locales.Locale
  alias TdI18n.Messages.Message
  alias TdI18n.Repo

  require Logger

  def list_locales(opts \\ [preload: :messages]) do
    preloads = Keyword.get(opts, :preload, [])

    Locale
    |> preload(^preloads)
    |> Repo.all()
  end

  def get_by!(clauses) do
    Locale
    |> Repo.get_by!(clauses)
    |> Repo.preload(:messages)
  end

  def get_locale!(id) do
    Locale
    |> Repo.get!(id)
    |> Repo.preload(:messages)
  end

  def get_locale(id), do: Repo.get(Locale, id)

  def create_locale(params \\ %{}) do
    changeset = Locale.changeset(%Locale{messages: []}, params)

    Multi.new()
    |> Multi.run(:maybe_unset_default_locale, fn _, _ -> maybe_unset_default_locale(params) end)
    |> Multi.insert(:locale, changeset)
    |> Repo.transaction()
    |> then(&multi_result(&1))
  end

  def create_locales(new_locales \\ []) do
    inserted_locales =
      Enum.map(new_locales, fn new_locale ->
        {:ok, inserted_locale} = create_locale(new_locale)
        inserted_locale
      end)

    {:ok, inserted_locales}
  end

  def update_locale(
        locale,
        params
      ) do
    changeset = Locale.changeset(locale, params)

    Multi.new()
    |> Multi.run(:maybe_unset_default_locale, fn _, _ -> maybe_unset_default_locale(params) end)
    |> Multi.update(:locale, changeset)
    |> Multi.run(:copy_messages_from_default, fn _, multi ->
      copy_messages_from_default(multi, params)
    end)
    |> Repo.transaction()
    |> then(&multi_result(&1))
  end

  def delete_locale(%Locale{lang: lang} = locale) do
    Multi.new()
    |> Multi.delete(:locale, Repo.preload(locale, :messages))
    |> Multi.run(:cache, fn _, _ ->
      I18nCache.delete(lang)
    end)
    |> Repo.transaction()
    |> then(&multi_result(&1))
  end

  def load_messages_from_file!(path) do
    if File.regular?(path) do
      path
      |> File.read!()
      |> Jason.decode!()
      |> populate_enabled_locales()
      |> Enum.each(&do_load_locale_message!/1)
    else
      Logger.warn("File #{path} does not exist")
    end
  end

  def load_locales_from_file!(path) do
    if File.regular?(path) do
      path
      |> File.read!()
      |> Jason.decode!()
      |> do_load_locales()
    else
      Logger.warn("File #{path} does not exist")
    end
  end

  defp maybe_unset_default_locale(%{"is_default" => true}) do
    query = where(Locale, is_default: true)
    {:ok, Repo.update_all(query, set: [is_default: false])}
  end

  defp maybe_unset_default_locale(_params), do: {:ok, []}

  defp copy_messages_from_default(%{locale: %{lang: updated_lang_lang}}, %{"is_enabled" => true}) do
    messages =
      Locale
      |> Repo.get_by(is_default: true)
      |> Repo.preload(:messages)
      |> case do
        nil ->
          Locale
          |> limit(1)
          |> order_by([l], asc: l.id)
          |> Repo.one()
          |> Repo.preload(:messages)

        default_lang ->
          default_lang
      end
      |> Map.get(:messages)
      |> Enum.map(fn %{message_id: message_id, definition: message_definition} ->
        {message_id, message_definition}
      end)

    do_load_locale_message!({updated_lang_lang, messages})
  end

  defp copy_messages_from_default(_updated_lang, _params), do: {:ok, []}

  defp populate_enabled_locales(langs_messages) do
    default_lang =
      Locale
      |> Repo.get_by(is_default: true)
      |> case do
        nil ->
          Locale
          |> limit(1)
          |> order_by([l], asc: l.id)
          |> Repo.one()
          |> Map.get(:lang)

        %{lang: lang} ->
          lang
      end

    default_lang =
      case Map.has_key?(langs_messages, default_lang) do
        true ->
          default_lang

        false ->
          langs_messages
          |> Map.keys()
          |> hd()
      end

    messages_to_add = Map.get(langs_messages, default_lang)

    Locale
    |> where(is_enabled: true)
    |> select([s], s.lang)
    |> Repo.all()
    |> Enum.filter(fn lang -> !Enum.member?(Map.keys(langs_messages), lang) end)
    |> Enum.reduce(langs_messages, fn lang, langs_messages ->
      Map.put(langs_messages, lang, messages_to_add)
    end)
  end

  defp do_load_locale_message!({lang, messages}) do
    ts = DateTime.utc_now()
    %{messages: existing_messages, id: locale_id} = get_or_insert!(lang)

    existing_ids = Enum.map(existing_messages, & &1.message_id)

    entries =
      messages
      |> Enum.reject(fn {k, _} -> k in existing_ids end)
      |> Enum.map(fn {message_id, definition} ->
        %{
          message_id: message_id,
          definition: definition,
          inserted_at: ts,
          updated_at: ts,
          locale_id: locale_id
        }
      end)

    Multi.new()
    |> Multi.insert_all(:messages, Message, entries, on_conflict: :nothing)
    |> Multi.run(:cache, fn _, _ ->
      add_to_cache(lang, existing_messages, entries)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{messages: {0, _} = result}} ->
        Logger.info("No new messages for locale '#{lang}'")
        {:ok, result}

      {:ok, %{messages: {count, _} = result}} ->
        Logger.info("Loaded #{count} messages for locale '#{lang}'")
        {:ok, result}

      {:error, _, error, _} ->
        {:error, error}
    end
  end

  defp do_load_locales(locales) do
    ts = DateTime.utc_now()

    entries =
      Enum.map(locales, fn %{"lang" => lang, "name" => name, "local_name" => local_name} ->
        %{
          lang: lang,
          name: name,
          local_name: local_name,
          inserted_at: ts,
          updated_at: ts
        }
      end)

    Locale
    |> Repo.insert_all(entries, on_conflict: :nothing)
    |> case do
      {0, _} = result ->
        Logger.info("No new locales")
        {:ok, result}

      {count, _} = result ->
        Logger.info("Loaded #{count} new locales")
        {:ok, result}
    end
  end

  defp get_or_insert!(lang) do
    case Repo.get_by(Locale, lang: lang) do
      nil -> Repo.insert!(%Locale{lang: lang, messages: []})
      locale -> Repo.preload(locale, :messages)
    end
  end

  defp add_to_cache(lang, existing_messages, entries)

  defp add_to_cache(_lang, [], []), do: {:ok, []}

  defp add_to_cache(lang, existing_messages, entries) do
    existing_messages
    |> Kernel.++(entries)
    |> Enum.map(fn message ->
      {:ok, result} = I18nCache.put(lang, message)
      result
    end)
    |> then(&{:ok, &1})
  end

  defp multi_result({:ok, %{locale: changeset}}), do: {:ok, changeset}

  defp multi_result({:error, _, error, _}), do: {:error, error}
end
