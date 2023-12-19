defmodule TdI18n.AllLocales do
  @moduledoc """
  The AllLocales context.
  """
  require Logger

  alias TdI18n.AllLocales.AllLocale
  alias TdI18n.Repo

  def list_all_locale do
    Repo.all(AllLocale)
  end

  def load_from_file!(path) do
    if File.regular?(path) do
      path
      |> File.read!()
      |> Jason.decode!()
      |> do_load_codes!()
    else
      Logger.warn("File #{path} does not exist")
    end
  end

  defp do_load_codes!(locales) do
    ts = DateTime.utc_now()

    entries =
      Enum.map(locales, fn %{"code" => code, "local" => local, "name" => name} ->
        %{
          code: code,
          name: name,
          local: local,
          inserted_at: ts,
          updated_at: ts
        }
      end)

    Repo.insert_all(AllLocale, entries, on_conflict: :nothing)
    |> case do
      {0, _} = result ->
        Logger.info("No new locales")
        {:ok, result}

      {count, _} = result ->
        Logger.info("Loaded #{count} new locales")
        {:ok, result}
    end
  end
end
