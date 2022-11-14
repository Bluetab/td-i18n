defmodule TdI18n.Locales do
  @moduledoc """
  The Locales context.
  """

  import Ecto.Query

  alias TdI18n.Locales.Locale
  alias TdI18n.Repo

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
end
