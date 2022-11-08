defmodule TdI18n.Locales.Locale do
  @moduledoc """
  Ecto Schema module for i18n locales
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TdI18n.Messages.Message

  schema "locales" do
    field :is_default, :boolean, default: false
    field :lang, :string

    has_many :messages, Message

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(locale, attrs) do
    locale
    |> cast(attrs, [:lang, :is_default])
    |> validate_required([:lang, :is_default])
  end
end