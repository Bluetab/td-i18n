defmodule TdI18n.Locales do
  @moduledoc """
  The Locales context.
  """

  import Ecto.Query

  alias Ecto.Multi
  alias TdCache.I18nCache
  alias TdI18n.Cache.LocaleCache
  alias TdI18n.Cache.LocaleLoader
  alias TdI18n.Locales.Locale
  alias TdI18n.Messages.Message
  alias TdI18n.Repo
  require Logger

  def list_locales(opts \\ []) do
    preloads = Keyword.get(opts, :preload, [])
    filters = Keyword.get(opts, :filters, [])

    filters
    |> Enum.reduce(Locale, fn
      {:is_enabled, value}, query -> where(query, [l], l.is_enabled == ^value)
      {:is_default, value}, query -> where(query, [l], l.is_default == ^value)
      {:is_required, value}, query -> where(query, [l], l.is_required == ^value)
      {:lang, value}, query -> where(query, [l], l.lang == ^value)
    end)
    |> preload(^preloads)
    |> Repo.all()
  end

  def get_by!(clauses, opts \\ [preload: :messages]) do
    preloads = Keyword.get(opts, :preload, [])

    Locale
    |> preload(^preloads)
    |> Repo.get_by!(clauses)
  end

  def get_locale!(id, opts \\ [preload: :messages]) do
    preloads = Keyword.get(opts, :preload, [])

    Locale
    |> preload(^preloads)
    |> Repo.get!(id)
  end

  def get_locale(id), do: Repo.get(Locale, id)

  def get_first_locale do
    Locale
    |> limit(1)
    |> order_by([l], asc: l.id)
    |> Repo.one()
  end

  def get_default_locale do
    Repo.get_by(Locale, is_default: true)
  end

  def get_required_locales do
    Locale
    |> where([l], l.is_required and not l.is_default)
    |> Repo.all()
  end

  def create_locale(attrs \\ %{}) do
    Multi.new()
    |> Multi.run(:locale_changeset, fn _, _ -> {:ok, Locale.changeset(%Locale{}, attrs)} end)
    |> Multi.run(:maybe_unset_default, &maybe_unset_default/2)
    |> Multi.insert(:locale, & &1.locale_changeset)
    |> Repo.transaction()
    |> multi_result()
    |> maybe_create_default_messages()
    |> maybe_refresh_cache()
  end

  def create_locales(new_locales \\ []) do
    new_locales
    |> Enum.map(
      &(&1
        |> create_locale
        |> elem(1))
    )
    |> then(&{:ok, &1})
  end

  def update_locale(%Locale{} = locale, attrs) do
    Multi.new()
    |> Multi.run(:locale_changeset, fn _, _ -> {:ok, Locale.changeset(locale, attrs)} end)
    |> Multi.run(:maybe_unset_default, &maybe_unset_default/2)
    |> Multi.update(:locale, Locale.changeset(locale, attrs))
    |> Repo.transaction()
    |> multi_result()
    |> maybe_create_default_messages()
    |> maybe_refresh_cache()
  end

  def load_messages_from_file!(path) do
    if File.regular?(path) do
      Logger.info("Loading messages file")

      file_data =
        path
        |> File.read!()
        |> Jason.decode!()

      %{lang: default_lang} = get_default_locale() || get_first_locale()

      default_messages = Map.get(file_data, default_lang) || file_data |> Map.values() |> hd()

      Locale
      |> where(is_enabled: true)
      |> select([s], s.lang)
      |> Repo.all()
      |> Enum.filter(fn lang -> !Enum.member?(Map.keys(file_data), lang) end)
      |> Enum.reduce(file_data, &Map.put(&2, &1, default_messages))
      |> Enum.each(&do_load_locale_messages!/1)
    else
      Logger.warning("File #{path} does not exist")
    end
  end

  defp do_load_locale_messages!({lang, messages}) do
    ts = DateTime.utc_now()

    %{messages: existing_messages, id: locale_id} =
      case Repo.get_by(Locale, lang: lang) do
        nil -> Repo.insert!(%Locale{lang: lang, messages: []})
        locale -> Repo.preload(locale, :messages)
      end

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

  def load_locales_from_file!(path) do
    if File.regular?(path) do
      Logger.info("Loading locales file")
      ts = DateTime.utc_now()

      path
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(
        &%{
          lang: &1["lang"],
          name: &1["name"],
          local_name: &1["local_name"],
          inserted_at: ts,
          updated_at: ts
        }
      )
      |> then(&Repo.insert_all(Locale, &1, on_conflict: :nothing))
      |> case do
        {0, _} = result ->
          Logger.info("No new locales")
          {:ok, result}

        {count, _} = result ->
          Logger.info("Loaded #{count} new locales")
          {:ok, result}
      end
    else
      Logger.warning("File #{path} does not exist")
    end
  end

  defp maybe_create_default_messages({:ok, %{is_enabled: true, lang: lang}} = result) do
    messages =
      (get_default_locale() || get_first_locale())
      |> Repo.preload([:messages])
      |> Map.get(:messages)
      |> Enum.into(%{}, fn %{message_id: m_id, definition: m_def} -> {m_id, m_def} end)

    do_load_locale_messages!({lang, messages})
    result
  end

  defp maybe_create_default_messages(result), do: result

  defp maybe_refresh_cache({:ok, %{is_enabled: true} = locale} = result) do
    LocaleCache.refresh()
    LocaleLoader.put_default_and_required_locales()
    load_locale_messages(locale)
    result
  end

  defp maybe_refresh_cache({:ok, %{is_enabled: false, lang: lang}} = result) do
    LocaleCache.refresh()
    LocaleLoader.put_default_and_required_locales()
    I18nCache.delete(lang)
    result
  end

  defp maybe_refresh_cache(result), do: result

  defp maybe_unset_default(_, %{locale_changeset: %{changes: %{is_default: true}}}) do
    Locale
    |> where(is_default: true)
    |> Repo.update_all(set: [is_default: false])

    {:ok, nil}
  end

  defp maybe_unset_default(_, _), do: {:ok, nil}

  defp multi_result({:ok, %{locale: result}}), do: {:ok, result}
  defp multi_result({:error, _, error, _}), do: {:error, error}

  defp load_locale_messages(locale) do
    locale =
      Locale
      |> preload(:messages)
      |> Repo.get!(locale.id)

    Enum.each(locale.messages, fn message ->
      I18nCache.put(locale.lang, %{
        message_id: message.message_id,
        definition: message.definition
      })
    end)
  end
end
