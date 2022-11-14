defmodule TdI18n.LocalesTest do
  use TdI18n.DataCase

  alias TdI18n.Locales
  alias TdI18n.Locales.Locale

  test "list_locales/0 returns all locales" do
    locale = insert(:locale)
    assert Locales.list_locales() == [locale]
  end

  test "get_locale!/1 returns the locale with given id" do
    locale = insert(:locale)
    assert Locales.get_locale!(locale.id) == locale
  end

  test "create_locale/1 with valid data creates a locale" do
    valid_attrs = %{is_default: true, lang: "some lang"}

    assert {:ok, %Locale{} = locale} = Locales.create_locale(valid_attrs)
    assert locale.is_default == true
    assert locale.lang == "some lang"
  end

  test "create_locale/1 with invalid data returns error changeset" do
    params = %{lang: nil, is_default: nil}
    assert {:error, %Ecto.Changeset{}} = Locales.create_locale(params)
  end

  test "update_locale/2 with valid data updates the locale" do
    locale = insert(:locale)
    update_attrs = %{is_default: false, lang: "some updated lang"}

    assert {:ok, %Locale{} = locale} = Locales.update_locale(locale, update_attrs)
    assert locale.is_default == false
    assert locale.lang == "some updated lang"
  end

  test "update_locale/2 with invalid data returns error changeset" do
    locale = insert(:locale)
    params = %{lang: nil, is_default: nil}
    assert {:error, %Ecto.Changeset{}} = Locales.update_locale(locale, params)
    assert locale == Locales.get_locale!(locale.id)
  end

  test "delete_locale/1 deletes the locale" do
    locale = insert(:locale)
    assert {:ok, %Locale{}} = Locales.delete_locale(locale)
    assert_raise Ecto.NoResultsError, fn -> Locales.get_locale!(locale.id) end
  end
end
