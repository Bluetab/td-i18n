defmodule TdI18n.LocalesTest do
  use TdI18n.DataCase

  alias TdI18n.Locales

  describe "locales" do
    alias TdI18n.Locales.Locale

    import TdI18n.LocalesFixtures

    @invalid_attrs %{is_default: nil, lang: nil}

    test "list_locales/0 returns all locales" do
      locale = locale_fixture()
      assert Locales.list_locales() == [locale]
    end

    test "get_locale!/1 returns the locale with given id" do
      locale = locale_fixture()
      assert Locales.get_locale!(locale.id) == locale
    end

    test "create_locale/1 with valid data creates a locale" do
      valid_attrs = %{is_default: true, lang: "some lang"}

      assert {:ok, %Locale{} = locale} = Locales.create_locale(valid_attrs)
      assert locale.is_default == true
      assert locale.lang == "some lang"
    end

    test "create_locale/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locales.create_locale(@invalid_attrs)
    end

    test "update_locale/2 with valid data updates the locale" do
      locale = locale_fixture()
      update_attrs = %{is_default: false, lang: "some updated lang"}

      assert {:ok, %Locale{} = locale} = Locales.update_locale(locale, update_attrs)
      assert locale.is_default == false
      assert locale.lang == "some updated lang"
    end

    test "update_locale/2 with invalid data returns error changeset" do
      locale = locale_fixture()
      assert {:error, %Ecto.Changeset{}} = Locales.update_locale(locale, @invalid_attrs)
      assert locale == Locales.get_locale!(locale.id)
    end

    test "delete_locale/1 deletes the locale" do
      locale = locale_fixture()
      assert {:ok, %Locale{}} = Locales.delete_locale(locale)
      assert_raise Ecto.NoResultsError, fn -> Locales.get_locale!(locale.id) end
    end

    test "change_locale/1 returns a locale changeset" do
      locale = locale_fixture()
      assert %Ecto.Changeset{} = Locales.change_locale(locale)
    end
  end
end
