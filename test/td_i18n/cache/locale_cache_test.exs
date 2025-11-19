defmodule TdI18n.Cache.LocaleCacheTest do
  alias TdI18n.Locales.Locale
  use TdI18n.DataCase

  alias TdI18n.Cache.LocaleCache
  alias TdI18n.Locales
  alias TdI18n.Messages

  setup do
    # Clear the cache state before each test
    :sys.replace_state(LocaleCache, fn _state ->
      %{json: nil, refresh_count: 0, refresh_timer: nil, refresh_waiters: []}
    end)

    :ok
  end

  describe "locale cache" do
    test "populates cache on first read" do
      locale = insert(:locale, is_enabled: true)
      insert(:message, locale: locale)

      assert response = LocaleCache.get_locales()
      assert %{"data" => [rendered_locale]} = Jason.decode!(response)
      assert rendered_locale["id"] == locale.id
      assert length(rendered_locale["messages"]) == 1
    end

    test "returns cached data on subsequent reads" do
      locale = insert(:locale, is_enabled: true)
      message = insert(:message, locale: locale)

      # Multiple reads should return the same cached data
      first_read = LocaleCache.get_locales()
      second_read = LocaleCache.get_locales()
      third_read = LocaleCache.get_locales()

      assert first_read == second_read
      assert second_read == third_read

      decoded = Jason.decode!(first_read)
      assert %{"data" => [rendered_locale]} = decoded
      assert rendered_locale["id"] == locale.id
      assert [rendered_message] = rendered_locale["messages"]
      assert rendered_message["id"] == message.id
    end

    test "invalidates cache when new locale is created" do
      locale1 = insert(:locale, is_enabled: true)
      initial_data = LocaleCache.get_locales()

      {:ok, locale2} =
        Locales.create_locale(%{
          lang: "es",
          name: "Spanish",
          local_name: "Español",
          is_enabled: true
        })

      new_data = LocaleCache.get_locales()

      assert new_data != initial_data
      assert %{"data" => locales} = Jason.decode!(new_data)
      assert length(locales) == 2
      assert Enum.map(locales, & &1["id"]) |> Enum.sort() == [locale1.id, locale2.id]
    end

    test "invalidates cache when locale is updated" do
      locale = insert(:locale, is_enabled: true)
      insert(:message, locale: locale)
      initial_data = LocaleCache.get_locales()

      # Update locale
      locale = Repo.get!(Locale, locale.id)
      {:ok, _} = Locales.update_locale(locale, %{name: "Updated Name"})

      new_data = LocaleCache.get_locales()

      assert new_data != initial_data
      assert %{"data" => [rendered_locale]} = Jason.decode!(new_data)
      assert rendered_locale["name"] == "Updated Name"
    end

    test "invalidates cache when new message is created" do
      locale = insert(:locale, is_enabled: true)
      message1 = insert(:message, locale: locale)
      initial_data = LocaleCache.get_locales()

      # Create new message
      {:ok, message2} =
        Messages.create_message(locale, %{
          message_id: "test.new",
          definition: "New Message"
        })

      new_data = LocaleCache.get_locales()

      assert new_data != initial_data
      assert %{"data" => [rendered_locale]} = Jason.decode!(new_data)
      assert message_ids = Enum.map(rendered_locale["messages"], & &1["id"]) |> Enum.sort()
      assert message_ids == [message1.id, message2.id]
    end

    test "invalidates cache when message is updated" do
      locale = insert(:locale, is_enabled: true)
      message = insert(:message, locale: locale)
      initial_data = LocaleCache.get_locales()

      # Update message
      {:ok, _} = Messages.update_message(message, %{definition: "Updated Definition"})

      new_data = LocaleCache.get_locales()

      assert new_data != initial_data
      assert %{"data" => [rendered_locale]} = Jason.decode!(new_data)
      assert [rendered_message] = rendered_locale["messages"]
      assert rendered_message["definition"] == "Updated Definition"
    end

    test "handles multiple locales with messages" do
      locale1 = insert(:locale, lang: "en", is_enabled: true)
      locale2 = insert(:locale, lang: "es", is_enabled: true)
      insert(:message, locale: locale1, message_id: "greeting", definition: "Hello")
      insert(:message, locale: locale2, message_id: "greeting", definition: "Hola")

      response = LocaleCache.get_locales()
      assert %{"data" => locales} = Jason.decode!(response)
      assert length(locales) == 2

      [en_locale, es_locale] = Enum.sort_by(locales, & &1["lang"])
      assert en_locale["lang"] == "en"
      assert es_locale["lang"] == "es"
      assert [en_message] = en_locale["messages"]
      assert [es_message] = es_locale["messages"]
      assert en_message["definition"] == "Hello"
      assert es_message["definition"] == "Hola"
    end

    test "only caches enabled locales" do
      # Create enabled and disabled locales
      enabled_locale = insert(:locale, is_enabled: true)
      disabled_locale = insert(:locale, is_enabled: false)

      # Add messages to both
      enabled_message = insert(:message, locale: enabled_locale)
      _disabled_message = insert(:message, locale: disabled_locale)

      # Cache should only include enabled locale
      assert response = LocaleCache.get_locales()
      assert %{"data" => [rendered_locale]} = Jason.decode!(response)
      assert rendered_locale["id"] == enabled_locale.id
      assert [rendered_message] = rendered_locale["messages"]
      assert rendered_message["id"] == enabled_message.id

      # Enable the disabled locale
      {:ok, _} = TdI18n.Locales.update_locale(disabled_locale, %{is_enabled: true})

      # Cache should now include both locales
      assert response = LocaleCache.get_locales()
      assert %{"data" => locales} = Jason.decode!(response)
      assert length(locales) == 2

      assert Enum.map(locales, & &1["id"]) |> Enum.sort() == [
               enabled_locale.id,
               disabled_locale.id
             ]
    end

    test "get_locales waits for pending refresh" do
      locale = insert(:locale, is_enabled: true)
      initial_data = LocaleCache.get_locales()

      LocaleCache.refresh()

      {:ok, _} = Locales.update_locale(locale, %{name: "Updated During Refresh"})

      new_data = LocaleCache.get_locales()
      assert new_data != initial_data
      assert %{"data" => [rendered_locale]} = Jason.decode!(new_data)
      assert rendered_locale["name"] == "Updated During Refresh"
    end
  end

  describe "get_stats/0" do
    test "returns initial stats with zero refresh count" do
      assert %{refresh_count: 0} = LocaleCache.get_stats()
    end

    test "increments refresh count after cache refresh" do
      insert(:locale, is_enabled: true)

      assert %{refresh_count: 0} = LocaleCache.get_stats()

      LocaleCache.get_locales()
      assert %{refresh_count: 1} = LocaleCache.get_stats()

      LocaleCache.refresh()
      Process.sleep(50)
      assert %{refresh_count: 2} = LocaleCache.get_stats()
    end
  end

  describe "refresh/0" do
    test "ignores refresh when already pending" do
      insert(:locale, is_enabled: true)

      :sys.replace_state(LocaleCache, fn state ->
        %{state | refresh_timer: :pending}
      end)

      LocaleCache.refresh()

      state = :sys.get_state(LocaleCache)
      assert state.refresh_timer == :pending
    end

    test "triggers refresh when not pending" do
      insert(:locale, is_enabled: true)
      LocaleCache.get_locales()

      initial_stats = LocaleCache.get_stats()

      :sys.replace_state(LocaleCache, fn state ->
        %{state | refresh_timer: nil}
      end)

      LocaleCache.refresh()
      Process.sleep(50)

      new_stats = LocaleCache.get_stats()
      assert new_stats.refresh_count > initial_stats.refresh_count
    end
  end
end
