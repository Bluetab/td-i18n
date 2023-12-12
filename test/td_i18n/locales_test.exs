defmodule TdI18n.LocalesTest do
  use TdI18n.DataCase

  alias TdI18n.Locales
  alias TdI18n.Locales.Locale
  alias TdI18n.Repo

  test "list_locales/0 returns all locales" do
    locale = insert(:locale)
    assert Locales.list_locales() == [locale]
  end

  test "get_locale!/1 returns the locale with given id" do
    locale = insert(:locale)
    assert Locales.get_locale!(locale.id) == locale
  end

  test "get_by!/1 returns the locale with given lang" do
    locale = insert(:locale)
    assert Locales.get_by!(lang: locale.lang) == locale
  end

  describe "create_locale/1" do
    test "with valid data creates a locale" do
      valid_attrs = %{lang: "some lang", is_required: true, is_default: true}

      assert {:ok, %Locale{lang: "some lang", is_required: true, is_default: true}} =
               Locales.create_locale(valid_attrs)
    end

    test "with required data creates a locale with default values" do
      valid_attrs = %{lang: "some lang"}

      {:ok, locale} = Locales.create_locale(valid_attrs)

      assert %Locale{lang: "some lang", is_required: false, is_default: false} = locale
    end

    test "with require valid data creates a locale with default values" do
      valid_attrs = %{lang: "some lang"}

      {:ok, locale} = Locales.create_locale(valid_attrs)

      assert %Locale{lang: "some lang", is_required: false, is_default: false} = locale
    end

    test "with invalid data returns error changeset" do
      params = %{lang: "td"}

      assert {:error, %Ecto.Changeset{}} = Locales.create_locale(%{lang: nil})

      assert {:error, %Ecto.Changeset{}} =
               Locales.create_locale(Map.put(params, :is_required, "lorem"))

      assert {:error, %Ecto.Changeset{}} =
               Locales.create_locale(Map.put(params, :is_default, "ipsum"))
    end

    test "sets only 1 default" do
      %{id: id1, lang: lang1, is_default: true} = insert(:locale, lang: "td", is_default: true)

      {:ok, %{id: id2, lang: lang2}} =
        Locales.create_locale(%{"lang" => "bt", "is_default" => true})

      {:ok, %{id: id3, lang: lang3}} =
        Locales.create_locale(%{"lang" => "xx", "is_default" => false})

      assert %{id: ^id1, lang: ^lang1, is_default: false} = Repo.get(Locale, id1)

      assert %{id: ^id2, lang: ^lang2, is_default: true} = Repo.get(Locale, id2)

      assert %{id: ^id3, lang: ^lang3, is_default: false} = Repo.get(Locale, id3)
    end

    test "sets is_required when is_default" do
      assert {:ok, %{is_required: true}} =
               Locales.create_locale(%{"lang" => "td", "is_default" => true})

      assert {:ok, %{is_required: true}} =
               Locales.create_locale(%{
                 "lang" => "td",
                 "is_default" => true,
                 "is_required" => false
               })

      assert {:ok, %{is_required: true}} =
               Locales.create_locale(%{
                 "lang" => "td",
                 "is_default" => true,
                 "is_required" => true
               })
    end
  end

  describe "update_locale/2" do
    test "with valid data updates the locale" do
      messages =
        Enum.map(1..5, fn _ ->
          insert(:message)
        end)

      locale = insert(:locale, messages: messages)

      update_attrs = %{lang: "some updated lang", is_required: true, is_default: true}

      assert {:ok, %Locale{lang: "some updated lang", is_required: true, is_default: true}} =
               Locales.update_locale(locale, update_attrs)
    end

    test "with invalid data returns error changeset" do
      locale = insert(:locale)
      params = %{lang: "td"}

      assert {:error, %Ecto.Changeset{}} = Locales.update_locale(locale, %{lang: nil})

      assert {:error, %Ecto.Changeset{}} =
               Locales.update_locale(locale, Map.put(params, :is_required, "lorem"))

      assert {:error, %Ecto.Changeset{}} =
               Locales.update_locale(locale, Map.put(params, :is_default, "ipsum"))
    end

    test "with required data updates a locale with default values" do
      locale = insert(:locale)
      valid_attrs = %{lang: "some lang"}

      {:ok, locale} = Locales.update_locale(locale, valid_attrs)

      assert %Locale{lang: "some lang", is_required: false, is_default: false} = locale
    end

    test "with require valid data updates a locale with default values" do
      locale = insert(:locale)
      valid_attrs = %{lang: "some lang"}

      {:ok, locale} = Locales.update_locale(locale, valid_attrs)

      assert %Locale{lang: "some lang", is_required: false, is_default: false} = locale
    end

    test "sets only 1 default" do
      %{id: id1, lang: lang1, is_default: true} = insert(:locale, lang: "td", is_default: true)

      locale2 = insert(:locale)

      {:ok, %{id: id2, lang: lang2}} =
        Locales.update_locale(locale2, %{"lang" => "bt", "is_default" => true})

      locale3 = insert(:locale)

      {:ok, %{id: id3, lang: lang3}} =
        Locales.update_locale(locale3, %{"lang" => "xx", "is_default" => false})

      assert %{id: ^id1, lang: ^lang1, is_default: false} = Repo.get(Locale, id1)

      assert %{id: ^id2, lang: ^lang2, is_default: true} = Repo.get(Locale, id2)

      assert %{id: ^id3, lang: ^lang3, is_default: false} = Repo.get(Locale, id3)
    end

    test "sets is_required when is_default" do
      locale1 = insert(:locale)
      locale2 = insert(:locale)
      locale3 = insert(:locale)

      assert {:ok, %{is_required: true}} =
               Locales.update_locale(locale1, %{"lang" => "td", "is_default" => true})

      assert {:ok, %{is_required: true}} =
               Locales.update_locale(locale2, %{
                 "lang" => "td",
                 "is_default" => true,
                 "is_required" => false
               })

      assert {:ok, %{is_required: true}} =
               Locales.update_locale(locale3, %{
                 "lang" => "td",
                 "is_default" => true,
                 "is_required" => true
               })
    end
  end

  test "delete_locale/1 deletes the locale" do
    locale = insert(:locale)
    assert {:ok, %Locale{}} = Locales.delete_locale(locale)
    assert_raise Ecto.NoResultsError, fn -> Locales.get_locale!(locale.id) end
  end
end
