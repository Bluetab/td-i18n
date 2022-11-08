defmodule TdI18n.Factory do
  @moduledoc """
  Factory methods for tests
  """

  use ExMachina.Ecto, repo: TdI18n.Repo

  alias TdI18n.Locales.Locale
  alias TdI18n.Messages.Message

  def locale_factory do
    %Locale{
      lang: sequence("locale_lang")
    }
  end

  def message_factory(attrs) do
    attrs = default_assoc(attrs, :locale_id, :locale)

    %Message{
      message_id: sequence("message_id"),
      definition: sequence("message_definition"),
      description: sequence("message_description")
    }
    |> merge_attributes(attrs)
  end

  defp default_assoc(attrs, id_key, key) do
    if Enum.any?([key, id_key], &Map.has_key?(attrs, &1)) do
      attrs
    else
      Map.put(attrs, key, build(key))
    end
  end
end
