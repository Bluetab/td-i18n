defmodule TdI18n.Locales do
  @moduledoc """
  The Locales context.
  """

  import Ecto.Query

  alias TdI18n.Locales.Locale
  alias TdI18n.Messages.Message
  alias TdI18n.Repo

  require Logger

  def list_locales do
    Locale
    |> preload(:messages)
    |> Repo.all()
  end

  def get_locale!(id) do
    Locale
    |> preload(:messages)
    |> Repo.get!(id)
    |> Repo.preload(:messages)
  end

  def create_locale(params \\ %{}) do
    %Locale{messages: []}
    |> Locale.changeset(params)
    |> Repo.insert()
  end

  def update_locale(%Locale{} = locale, params) do
    locale
    |> Repo.preload(:messages)
    |> Locale.changeset(params)
    |> Repo.update()
  end

  def delete_locale(%Locale{} = locale) do
    locale
    |> Repo.preload(:messages)
    |> Repo.delete()
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

    case Repo.insert_all(Message, entries, on_conflict: :nothing) do
      {0, _} -> Logger.info("No new messages for locale '#{lang}'")
      {count, _} -> Logger.info("Loaded #{count} messages for locale '#{lang}'")
    end
  end

  defp get_or_insert!(lang) do
    case Repo.get_by(Locale, lang: lang) do
      nil -> Repo.insert!(%Locale{lang: lang, messages: []})
      locale -> Repo.preload(locale, :messages)
    end
  end
end
