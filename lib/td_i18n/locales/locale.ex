defmodule TdI18n.Locales.Locale do
  @moduledoc """
  Ecto Schema module for i18n locales
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TdI18n.Messages.Message

  schema "locales" do
    field :lang, :string
    field :is_default, :boolean, default: false
    field :is_required, :boolean, default: false
    field :is_enabled, :boolean, default: false
    field :name, :string
    field :local_name, :string

    has_many :messages, Message

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(locale, attrs) do
    locale
    |> cast(maybe_required(attrs), [
      :lang,
      :is_default,
      :is_required,
      :is_enabled,
      :name,
      :local_name
    ])
    |> validate_required([:lang, :name, :local_name])
    |> unique_constraint(:lang)
  end

  defp maybe_required(%{"is_default" => true} = attrs), do: Map.put(attrs, "is_required", true)

  defp maybe_required(attrs), do: attrs
end
