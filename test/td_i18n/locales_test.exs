defmodule TdI18n.LocalesTest do
  use TdI18n.DataCase

  import TdI18n.TestOperators

  alias TdCache.I18nCache
  alias TdI18n.Locales
  alias TdI18n.Locales.Locale
  alias TdI18n.Repo

  setup do
    TdCache.Redix.del!("i18n:*")
    on_exit(fn -> TdCache.Redix.del!("i18n:*") end)
  end

  describe "get and lis locales" do
    test "list_locales/0 returns all locales" do
      locale = insert(:locale)
      assert [result] = Locales.list_locales()
      assert result.id == locale.id
    end

    test "get_locale!/1 returns the locale with given id" do
      locale = insert(:locale)
      assert Locales.get_locale!(locale.id) == locale
    end

    test "get_by!/1 returns the locale with given lang" do
      locale = insert(:locale)
      assert Locales.get_by!(lang: locale.lang) == locale
    end

    test "get_default_locale/0 return default locale" do
      insert(:locale)
      assert is_nil(Locales.get_default_locale())

      %{id: default_locale_id} = insert(:locale, is_default: true)

      assert %{id: ^default_locale_id} = Locales.get_default_locale()
    end

    test "get_required_locales/0 return a required locales without default locale" do
      insert(:locale, is_required: true, is_default: true)
      assert [] == Locales.get_required_locales()
      %{id: required_id_1} = insert(:locale, is_required: true)

      %{id: required_id_2} = insert(:locale, is_required: true)

      [%{id: response_id_1}, %{id: response_id_2}] = Locales.get_required_locales()

      assert [required_id_1, required_id_2] ||| [response_id_1, response_id_2]
    end
  end

  describe "create_locale/1" do
    @valid_attrs %{
      lang: "some lang",
      is_required: true,
      is_default: true,
      is_enabled: true,
      name: "Some Name",
      local_name: "Some LocalName"
    }

    test "with valid data creates a locale" do
      assert {:ok, locale} = Locales.create_locale(@valid_attrs)

      assert_maps_equal(locale, @valid_attrs, [:name, :local_name])
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

    test "add to cache the locale when is created if is_default equal true" do
      assert {:ok, %Locale{lang: lang}} = Locales.create_locale(@valid_attrs)

      assert {:ok, ^lang} = I18nCache.get_default_locale()
    end

    test "no add to cache the locale when is created if is_default equal false" do
      insert(:locale, lang: "foo", is_default: true)
      {:ok, _} = I18nCache.put_default_locale("foo")

      assert {:ok, _} =
               @valid_attrs
               |> Map.put(:is_default, false)
               |> Map.put(:is_enabled, false)
               |> Locales.create_locale()

      assert {:ok, "foo"} = I18nCache.get_default_locale()
    end

    test "add to cache the locale when is created if is_required equal true" do
      assert {:ok, %Locale{lang: lang}} =
               @valid_attrs
               |> Map.put(:is_default, false)
               |> Locales.create_locale()

      assert {:ok, [^lang]} = I18nCache.get_required_locales()

      assert {:ok, %Locale{lang: new_lang}} =
               @valid_attrs
               |> Map.put(:lang, "foo")
               |> Map.put(:is_default, false)
               |> Locales.create_locale()

      assert {:ok, list_locales} = I18nCache.get_required_locales()

      assert [new_lang, lang] ||| list_locales
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

      assert {:ok, locale} = Locales.update_locale(locale, update_attrs)

      assert_maps_equal(locale, update_attrs, [:lang, :name, :local_name])
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

      assert_maps_equal(locale, valid_attrs, [:lang, :name, :local_name])
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

    test "add to cache the locale if is_default equal true" do
      locale = insert(:locale, is_default: false, is_required: false)

      update_attrs = %{is_default: true}

      assert {:ok, %{lang: lang}} = Locales.update_locale(locale, update_attrs)
      assert {:ok, ^lang} = I18nCache.get_default_locale()
    end

    test "add to cache the locale if is_required equal true" do
      locale = insert(:locale, is_default: false, is_required: false)

      update_attrs = %{is_required: true}

      assert {:ok, %{lang: lang}} = Locales.update_locale(locale, update_attrs)
      assert {:ok, [^lang]} = I18nCache.get_required_locales()
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

      assert [%{lang: "td"}] = Locales.list_locales()

      assert {:ok, {2, _}} = Locales.load_locales_from_file!("test/fixtures/locales_test.json")
      assert 3 == Enum.count(Locales.list_locales())

      assert {:ok, {0, _}} = Locales.load_locales_from_file!("test/fixtures/locales_test.json")
      assert 3 == Enum.count(Locales.list_locales())
    end
  end

  describe "cache synchronization" do
    test "enabling/disabling locales updates active locales in cache" do
      locale1 = insert(:locale, lang: "en", is_default: true, is_enabled: true)
      locale2 = insert(:locale, lang: "es", is_enabled: false)

      message1 = insert(:message, locale_id: locale1.id)

      I18nCache.put(locale1.lang, message1)

      assert I18nCache.get_active_locales!() == ["en"]

      {:ok, _} = Locales.update_locale(locale2, %{is_enabled: true})
      assert I18nCache.get_active_locales!() ||| ["en", "es"]

      {:ok, _} = Locales.update_locale(locale1, %{is_enabled: false})
      assert I18nCache.get_active_locales!() == ["es"]
    end

    test "changing required locales updates cache" do
      # Set up initial state
      locale1 = insert(:locale, lang: "en", is_required: true)
      locale2 = insert(:locale, lang: "es")
      locale3 = insert(:locale, lang: "fr")
      I18nCache.put_required_locales([locale1.lang])

      # Add another required locale - context should update cache
      {:ok, _} = Locales.update_locale(locale2, %{is_required: true})
      {:ok, required} = I18nCache.get_required_locales()
      assert Enum.sort(required) == ["en", "es"]

      # Remove first required locale - context should update cache
      {:ok, _} = Locales.update_locale(locale1, %{is_required: false})
      assert {:ok, ["es"]} = I18nCache.get_required_locales()

      # Add third required locale - context should update cache
      {:ok, _} = Locales.update_locale(locale3, %{is_required: true})
      {:ok, required} = I18nCache.get_required_locales()
      assert Enum.sort(required) == ["es", "fr"]
    end
  end
end
