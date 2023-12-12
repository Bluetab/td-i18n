defmodule TdI18n.AllLocales.AllLocale do
  @moduledoc """
  Ecto Schema module for i18n all_locale
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "all_locales" do
    field :name, :string
    field :local, :string
    field :code, :string

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :local, :code])
    |> validate_required([:name, :local, :code])
  end
end
