defmodule TdI18n.LocalesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TdI18n.Locales` context.
  """

  @doc """
  Generate a locale.
  """
  def locale_fixture(attrs \\ %{}) do
    {:ok, locale} =
      attrs
      |> Enum.into(%{
        is_default: true,
        lang: "some lang"
      })
      |> TdI18n.Locales.create_locale()

    locale
  end
end
