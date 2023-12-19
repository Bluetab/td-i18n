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
        {:ok, inserted_locale} = create_locale(%{lang: new_locale})
        inserted_locale
      end)

    {:ok, inserted_locales}
  end

  def update_locale(
        %Locale{lang: lang} = locale,
        %{"lang" => lang, "is_default" => _, "is_required" => _} = params
      ) do
    changeset = Locale.changeset(locale, params)

    Multi.new()
    |> Multi.run(:maybe_unset_default_locale, fn _, _ -> maybe_unset_default_locale(params) end)
    |> Multi.update(:locale, changeset)
    |> Repo.transaction()
    |> then(&multi_result(&1))
  end

  def update_locale(%Locale{lang: old_lang} = locale, params) do
    changeset =
      locale
      |> Repo.preload(:messages)
      |> Locale.changeset(params)

    Multi.new()
    |> Multi.run(:maybe_unset_default_locale, fn _, _ -> maybe_unset_default_locale(params) end)
    |> Multi.update(:locale, changeset)
    |> Multi.run(:delete_old_lang, fn _, _ ->
      I18nCache.delete(old_lang)
    end)
    |> Multi.run(:delete_lang, fn _, %{locale: %{lang: lang}} ->
      I18nCache.delete(lang)
    end)
    |> Multi.run(:cache, fn _, %{locale: %{lang: lang, messages: messages}} ->
      add_to_cache(lang, messages)
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

  def load_from_file!(path) do
    if File.regular?(path) do
      path
      |> File.read!()
      |> Jason.decode!()
      |> Enum.each(&do_load_locale!/1)
    else
      Logger.warn("File #{path} does not exist")
    end
  end

  defp maybe_unset_default_locale(%{"is_default" => true}) do
    query = where(Locale, is_default: true)
    {:ok, Repo.update_all(query, set: [is_default: false])}
  end

  defp maybe_unset_default_locale(_params), do: {:ok, []}

  defp do_load_locale!({lang, messages}) do
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

  defp get_or_insert!(lang) do
    case Repo.get_by(Locale, lang: lang) do
      nil -> Repo.insert!(%Locale{lang: lang, messages: []})
      locale -> Repo.preload(locale, :messages)
    end
  end

  defp add_to_cache(lang, existing_messages, entries \\ [])

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
