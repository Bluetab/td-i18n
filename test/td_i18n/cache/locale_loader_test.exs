defmodule TdI18n.Cache.LocaleLoaderTest do
  use TdI18n.DataCase

  alias TdCache.I18nCache
  alias TdI18n.Cache.LocaleLoader

  setup do
    on_exit(fn ->
      # Clean up all i18n related keys
      TdCache.Redix.del!("i18n:*")
    end)
  end

  describe "reload/0" do
    test "returns 'en' as default when no default locale exists" do
      assert {:ok, {"en", 0}} = LocaleLoader.reload()
      assert {:ok, "en"} = I18nCache.get_default_locale()
      assert {:ok, []} = I18nCache.get_required_locales()
    end

    test "sets default locale and required locales in cache" do
      # Setup test data
      _default_locale = insert(:locale, lang: "es", is_default: true, is_required: true)
      insert(:locale, lang: "fr", is_required: true)
      insert(:locale, lang: "de", is_required: true)

      assert {:ok, {"es", 2}} = LocaleLoader.reload()

      # Verify cache state
      assert {:ok, "es"} = I18nCache.get_default_locale()
      assert {:ok, required} = I18nCache.get_required_locales()
      assert Enum.sort(required) == ["de", "fr"]
    end

    test "cleans previous cache data before reload" do
      # Setup initial state
      {:ok, _} = I18nCache.put_default_locale("fr")
      {:ok, _} = I18nCache.put_required_locales(["it", "de"])

      # Create new state
      insert(:locale, lang: "es", is_default: true)
      insert(:locale, lang: "en", is_required: true)

      assert {:ok, {"es", 1}} = LocaleLoader.reload()

      # Verify old data is gone and new data is present
      assert {:ok, "es"} = I18nCache.get_default_locale()
      assert {:ok, required} = I18nCache.get_required_locales()
      assert required == ["en"]
    end

    test "only enabled locales are included in active_locales" do
      # Setup test data
      en_locale = insert(:locale, lang: "en", is_enabled: true)
      fr_locale = insert(:locale, lang: "fr", is_enabled: false)
      es_locale = insert(:locale, lang: "es", is_enabled: true)

      # Add some messages to make the locales active
      insert(:message, locale: en_locale, message_id: "test.key", definition: "test")
      insert(:message, locale: fr_locale, message_id: "test.key", definition: "invalid")
      insert(:message, locale: es_locale, message_id: "test.key", definition: "prueba")

      I18nCache.put(fr_locale.lang, %{message_id: "test.key", definition: "invalid"})

      assert {:ok, _} = LocaleLoader.reload()

      active_locales = I18nCache.get_active_locales!()
      assert Enum.sort(active_locales) == ["en", "es"]
      refute "fr" in active_locales
    end

    test "messages from disabled locales are not present in cache" do
      disabled_locale = insert(:locale, lang: "fr", is_enabled: false)
      enabled_locale = insert(:locale, lang: "es", is_enabled: true)

      disabled_message =
        insert(:message,
          locale: disabled_locale,
          message_id: "test.key",
          definition: "test value"
        )

      enabled_message =
        insert(:message,
          locale: enabled_locale,
          message_id: "test.key",
          definition: "test value"
        )

      I18nCache.put(enabled_locale.lang, enabled_message)
      I18nCache.put(disabled_locale.lang, disabled_message)

      assert {:ok, _} = LocaleLoader.reload()

      # Verify cache state
      assert I18nCache.get_definition(enabled_locale.lang, "test.key") == "test value"
      assert I18nCache.get_definition(disabled_locale.lang, "test.key") == nil
    end
  end
end
