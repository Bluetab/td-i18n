defmodule TdI18n.Messages.Message do
  @moduledoc """
  Ecto Schema module for i18n messages
  """

  use Ecto.Schema

  alias TdI18n.Locales.Locale

  import Ecto.Changeset

  schema "messages" do
    belongs_to :locale, Locale

    field :message_id, :string
    field :definition, :string
    field :description, :string

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:definition, :description, :message_id])
    |> validate_required([:definition, :description, :message_id])
    |> foreign_key_constraint(:locale)
    |> unique_constraint([:locale_id, :message_id])
  end
end
