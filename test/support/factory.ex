defmodule TdI18n.Factory do
  @moduledoc """
  Factory methods for tests
  """

  use ExMachina.Ecto, repo: TdI18n.Repo

  alias TdI18n.AllLocales.AllLocale
  alias TdI18n.Locales.Locale
  alias TdI18n.Messages.Message

  def locale_factory do
    %Locale{
      lang: sequence("locale_lang"),
      messages: []
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

  def all_locale_factory do
    %AllLocale{
      code: "td",
      name: "Truedat",
      local: "Trudish"
    }
  end

  def user_factory do
    %{
      id: System.unique_integer([:positive]),
      user_name: sequence("user_name"),
      full_name: sequence("full_name"),
      external_id: sequence("user_external_id"),
      email: sequence("email") <> "@example.com"
    }
  end

  defp default_assoc(attrs, id_key, key) do
    if Enum.any?([key, id_key], &Map.has_key?(attrs, &1)) do
      attrs
    else
      Map.put(attrs, key, build(key))
    end
  end
end
