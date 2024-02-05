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
      valid_attrs = %{
        lang: "some lang",
        is_required: true,
        is_default: true,
        is_enabled: true,
        name: "Some Name",
        local_name: "Some LocalName"
      }

      assert {:ok,
              %Locale{
                lang: "some lang",
                is_required: true,
                is_default: true,
                is_enabled: true,
                name: "Some Name",
                local_name: "Some LocalName"
              }} = Locales.create_locale(valid_attrs)
    end

    test "with required data creates a locale with default values" do
      valid_attrs = %{lang: "some lang", name: "Some Name", local_name: "Some LocalName"}

      {:ok, locale} = Locales.create_locale(valid_attrs)

      assert %Locale{
               lang: "some lang",
               is_required: false,
               is_default: false,
               is_enabled: false,
               name: "Some Name",
               local_name: "Some LocalName"
             } = locale
    end

    test "with invalid data returns error changeset" do
      params = %{lang: "some lang", name: "Some Name", local_name: "Some LocalName"}

      assert {:error, %Ecto.Changeset{}} = Locales.create_locale(Map.put(params, :lang, nil))

      assert {:error, %Ecto.Changeset{}} = Locales.create_locale(Map.put(params, :name, nil))

      assert {:error, %Ecto.Changeset{}} =
               Locales.create_locale(Map.put(params, :local_name, nil))

      assert {:error, %Ecto.Changeset{}} =
               Locales.create_locale(Map.put(params, :is_required, "lorem"))

      assert {:error, %Ecto.Changeset{}} =
               Locales.create_locale(Map.put(params, :is_default, "ipsum"))

      assert {:error, %Ecto.Changeset{}} =
               Locales.create_locale(Map.put(params, :is_enabled, "ipsum"))
    end

    test "sets only 1 default" do
      %{id: id1, lang: lang1, is_default: true} = insert(:locale, lang: "td", is_default: true)

      {:ok, %{id: id2, lang: lang2}} =
        Locales.create_locale(%{
          "lang" => "bt",
          "is_default" => true,
          "name" => "Bluetab",
          "local_name" => "Bluetarian"
        })

      {:ok, %{id: id3, lang: lang3}} =
        Locales.create_locale(%{
          "lang" => "xx",
          "is_default" => false,
          "name" => "XenoXtream",
          "local_name" => "XenoXtreamer"
        })

      assert %{id: ^id1, lang: ^lang1, is_default: false} = Repo.get(Locale, id1)

      assert %{id: ^id2, lang: ^lang2, is_default: true} = Repo.get(Locale, id2)

      assert %{id: ^id3, lang: ^lang3, is_default: false} = Repo.get(Locale, id3)
    end

    test "sets is_required when is_default" do
      assert {:ok, %{is_required: true}} =
               Locales.create_locale(%{
                 "lang" => "td",
                 "is_default" => true,
                 "name" => "Truedat",
                 "local_name" => "Truedish"
               })

      assert {:ok, %{is_required: true}} =
               Locales.create_locale(%{
                 "lang" => "bt",
                 "is_default" => true,
                 "is_required" => false,
                 "name" => "Bluetab",
                 "local_name" => "Blutabian"
               })

      assert {:ok, %{is_required: true}} =
               Locales.create_locale(%{
                 "lang" => "xx",
                 "is_default" => true,
                 "is_required" => true,
                 "name" => "XenoXtream",
                 "local_name" => "XenoXtreamer"
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

      update_attrs = %{
        lang: "some updated lang",
        is_required: true,
        is_default: true,
        is_enabled: true,
        name: "Some Updated Name",
        local_name: "Some Updated LocalName"
      }

      assert {:ok,
              %Locale{
                lang: "some updated lang",
                is_required: true,
                is_default: true,
                is_enabled: true,
                name: "Some Updated Name",
                local_name: "Some Updated LocalName"
              }} = Locales.update_locale(locale, update_attrs)
    end

    test "with invalid data returns error changeset" do
      locale = insert(:locale)
      params = %{lang: "td", name: "Truedat", local_name: "Truedish"}

      assert {:error, %Ecto.Changeset{}} =
               Locales.update_locale(locale, Map.put(params, :lang, nil))

      assert {:error, %Ecto.Changeset{}} =
               Locales.update_locale(locale, Map.put(params, :name, nil))

      assert {:error, %Ecto.Changeset{}} =
               Locales.update_locale(locale, Map.put(params, :local_name, nil))

      assert {:error, %Ecto.Changeset{}} =
               Locales.update_locale(locale, Map.put(params, :is_required, "lorem"))

      assert {:error, %Ecto.Changeset{}} =
               Locales.update_locale(locale, Map.put(params, :is_default, "ipsum"))

      assert {:error, %Ecto.Changeset{}} =
               Locales.update_locale(locale, Map.put(params, :is_enabled, "ipsum"))
    end

    test "with required data updates a locale with default values" do
      locale = insert(:locale)

      valid_attrs = %{
        lang: "some updated lang",
        name: "Some Updated Name",
        local_name: "Some Updated LocalName"
      }

      {:ok, locale} = Locales.update_locale(locale, valid_attrs)

      assert %Locale{
               lang: "some updated lang",
               is_required: false,
               is_default: false,
               is_enabled: false,
               name: "Some Updated Name",
               local_name: "Some Updated LocalName"
             } = locale
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
      %{lang: lang1} = locale1 = insert(:locale)
      %{lang: lang2} = locale2 = insert(:locale)
      %{lang: lang3} = locale3 = insert(:locale)

      assert {:ok, %{is_required: true}} =
               Locales.update_locale(locale1, %{"lang" => lang1, "is_default" => true})

      assert {:ok, %{is_required: true}} =
               Locales.update_locale(locale2, %{
                 "lang" => lang2,
                 "is_default" => true,
                 "is_required" => false
               })

      assert {:ok, %{is_required: true}} =
               Locales.update_locale(locale3, %{
                 "lang" => lang3,
                 "is_default" => true,
                 "is_required" => true
               })
    end

    test "sets is_enabled" do
      %{lang: lang} = locale = insert(:locale)

      assert {:ok, %{is_enabled: true}} =
               Locales.update_locale(locale, %{"lang" => lang, "is_enabled" => true})

      assert {:ok, %{is_enabled: false}} =
               Locales.update_locale(locale, %{"lang" => lang, "is_enabled" => false})
    end
  end

  test "enabling a locale copy messages from default lang or from first lang in Locales" do
    %{id: en_locale_id} = insert(:locale, lang: "en", is_enabled: true)

    en_messages =
      Enum.map(1..3, fn _ ->
        %{message_id: message_id, definition: message_definition} =
          insert(:message, locale_id: en_locale_id)

        {message_id, message_definition}
      end)

    %{id: enable_locale_id, lang: enable_locale_lang} = enable_locale = insert(:locale)

    Locales.update_locale(enable_locale, %{
      "lang" => enable_locale_lang,
      "is_enabled" => true
    })

    enable_locale_id
    |> Locales.get_locale!()
    |> Map.get(:messages)
    |> Enum.map(fn %{message_id: message_id, definition: definition} ->
      assert Enum.member?(en_messages, {message_id, definition})
    end)

    Locales.update_locale(enable_locale, %{
      "lang" => enable_locale_lang,
      "is_enabled" => false
    })

    %{id: default_locale_id, lang: default_locale_lang} = default_locale = insert(:locale)

    Locales.update_locale(default_locale, %{
      "lang" => default_locale_lang,
      "is_enabled" => true,
      "is_default" => true
    })

    default_messages =
      Enum.map(1..3, fn _ ->
        %{message_id: message_id, definition: message_definition} =
          insert(:message, locale_id: default_locale_id)

        {message_id, message_definition}
      end)

    Locales.update_locale(enable_locale, %{
      "lang" => enable_locale_lang,
      "is_enabled" => true
    })

    assert enable_locale_id
           |> Locales.get_locale!()
           |> Map.get(:messages)
           |> Enum.map(fn %{message_id: message_id, definition: definition} ->
             assert Enum.member?(
                      Enum.concat(en_messages, default_messages),
                      {message_id, definition}
                    )
           end)
  end

  test "delete_locale/1 deletes the locale" do
    locale = insert(:locale)
    assert {:ok, %Locale{}} = Locales.delete_locale(locale)
    assert_raise Ecto.NoResultsError, fn -> Locales.get_locale!(locale.id) end
  end

  describe "load_messages_from_file!/1" do
    test "creates new locale and load messages" do
      insert(:locale)
      assert :ok = Locales.load_messages_from_file!("test/fixtures/messages_test.json")

      assert %{
               lang: "td",
               messages: [
                 %{
                   definition: "Test Message",
                   message_id: "test.message"
                 },
                 %{
                   definition: "Test Message Key",
                   message_id: "test.message.key"
                 }
               ]
             } = Locales.get_by!(lang: "td")
    end

    test "load messages on existing locale" do
      %{id: locale_id} = insert(:locale, lang: "td")

      insert(:message, message_id: "test", definition: "Test", locale_id: locale_id)

      Locales.load_messages_from_file!("test/fixtures/messages_test.json")

      assert %{
               lang: "td",
               messages: [
                 %{
                   definition: "Test",
                   message_id: "test"
                 },
                 %{
                   definition: "Test Message",
                   message_id: "test.message"
                 },
                 %{
                   definition: "Test Message Key",
                   message_id: "test.message.key"
                 }
               ]
             } = Locales.get_by!(lang: "td")
    end

    test "load maintained first lang in Locales messages on enabled locales when no default set" do
      %{id: main_locale_id} = insert(:locale, lang: "td")

      %{id: secondary_locale_id} = insert(:locale, lang: "bt", is_enabled: true)

      Enum.map([main_locale_id, secondary_locale_id], fn locale_id ->
        insert(:message, message_id: "test", definition: "Test", locale_id: locale_id)
      end)

      Locales.load_messages_from_file!("test/fixtures/messages_test.json")

      assert %{
               lang: "bt",
               messages: [
                 %{
                   definition: "Test",
                   message_id: "test"
                 },
                 %{
                   definition: "Test Message",
                   message_id: "test.message"
                 },
                 %{
                   definition: "Test Message Key",
                   message_id: "test.message.key"
                 }
               ]
             } = Locales.get_by!(lang: "bt")
    end

    test "load default lang found in file messages on enabled locales" do
      %{id: main_locale_id} = insert(:locale, lang: "td", is_enabled: true, is_default: true)

      %{id: secondary_locale_id} = insert(:locale, lang: "bt", is_enabled: true)

      Enum.map([main_locale_id, secondary_locale_id], fn locale_id ->
        insert(:message, message_id: "test", definition: "Test", locale_id: locale_id)
      end)

      Locales.load_messages_from_file!("test/fixtures/messages_test.json")

      assert %{
               lang: "bt",
               messages: [
                 %{
                   definition: "Test",
                   message_id: "test"
                 },
                 %{
                   definition: "Test Message",
                   message_id: "test.message"
                 },
                 %{
                   definition: "Test Message Key",
                   message_id: "test.message.key"
                 }
               ]
             } = Locales.get_by!(lang: "bt")
    end

    test "default lang not found in maintained file load first maintained lang messages on enabled locales" do
      %{id: main_locale_id} = insert(:locale, lang: "es", is_enabled: true, is_default: true)

      %{id: secondary_locale_id} = insert(:locale, lang: "bt", is_enabled: true)

      Enum.map([main_locale_id, secondary_locale_id], fn locale_id ->
        insert(:message, message_id: "test", definition: "Test", locale_id: locale_id)
      end)

      Locales.load_messages_from_file!("test/fixtures/messages_test.json")

      assert %{
               lang: "bt",
               messages: [
                 %{
                   definition: "Test",
                   message_id: "test"
                 },
                 %{
                   definition: "Test Message",
                   message_id: "test.message"
                 },
                 %{
                   definition: "Test Message Key",
                   message_id: "test.message.key"
                 }
               ]
             } = Locales.get_by!(lang: "bt")
    end
  end

  describe "load_locales_from_file!/1" do
    test "load locales without duplicating" do
      insert(:locale, lang: "td", name: "Truedat", local_name: "Truedish")

      assert 1 == Enum.count(Locales.list_locales())

      assert {:ok, {2, _}} = Locales.load_locales_from_file!("test/fixtures/locales_test.json")
      assert 3 == Enum.count(Locales.list_locales())

      assert {:ok, {0, _}} = Locales.load_locales_from_file!("test/fixtures/locales_test.json")
      assert 3 == Enum.count(Locales.list_locales())
    end
  end
end
