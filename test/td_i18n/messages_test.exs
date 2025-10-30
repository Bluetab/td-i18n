defmodule TdI18n.MessagesTest do
  use TdI18n.DataCase

  alias TdCache.I18nCache
  alias TdI18n.Messages
  alias TdI18n.Messages.Message

  test "list_messages/0 returns all messages" do
    message = insert(:message)

    Messages.list_messages()
    |> assert_lists_equal(
      [message],
      &assert_structs_equal(&1, &2, [:message_id, :description, :definition, :locale_id])
    )
  end

  test "get_message!/1 returns the message with given id" do
    message = insert(:message)

    assert Messages.get_message!(message.id)
           |> assert_structs_equal(message, [
             :id,
             :message_id,
             :definition,
             :description,
             :locale_id
           ])
  end

  test "create_message/1 with valid data creates a message" do
    %{id: locale_id, lang: lang} = locale = insert(:locale)

    %{
      definition: definition,
      description: description,
      message_id: message_id
    } = params = params_for(:message)

    assert {:ok, %Message{} = message} = Messages.create_message(locale, params)

    assert %{
             locale_id: ^locale_id,
             definition: ^definition,
             description: ^description,
             message_id: ^message_id
           } = message

    assert ^definition = I18nCache.get_definition(lang, message_id)
    on_exit(fn -> I18nCache.delete(lang) end)
  end

  test "create_message/1 with invalid data returns error changeset" do
    %{lang: lang} = locale = insert(:locale)
    params = %{definition: nil, description: nil}
    assert {:error, %Ecto.Changeset{}} = Messages.create_message(locale, params)
    on_exit(fn -> I18nCache.delete(lang) end)
  end

  test "update_message/2 with valid data updates the message" do
    %{message_id: message_id, locale: %{lang: lang}} = message = insert(:message)

    update_attrs = %{
      definition: "some updated definition",
      description: "some updated description"
    }

    assert {:ok, %Message{} = message} = Messages.update_message(message, update_attrs)

    assert message.definition == "some updated definition"
    assert message.description == "some updated description"

    assert message.definition == I18nCache.get_definition(lang, message_id)
    on_exit(fn -> I18nCache.delete(lang) end)
  end

  test "update_message/2 with invalid data returns error changeset" do
    message = insert(:message)
    params = %{definition: nil, description: nil}
    assert {:error, %Ecto.Changeset{}} = Messages.update_message(message, params)
  end

  test "delete_message/1 deletes the message" do
    %{message_id: message_id, definition: definition, locale: %{lang: lang}} =
      message = insert(:message)

    I18nCache.put(lang, %{message_id: message_id, definition: definition})

    assert {:ok, %Message{}} = Messages.delete_message(message)

    assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.id) end

    assert is_nil(I18nCache.get_definition(lang, message_id))
    on_exit(fn -> I18nCache.delete(lang) end)
  end

  describe "create_messages/2" do
    test "creates messages for multiple locales" do
      locale1 = insert(:locale, lang: "en")
      locale2 = insert(:locale, lang: "es")

      message_id = "test.message.multi"

      langs = [
        {locale1.id, %{"definition" => "Hello"}},
        {locale2.id, %{"definition" => "Hola"}}
      ]

      assert {:ok, messages} = Messages.create_messages(message_id, langs)

      assert length(messages) == 2

      assert Enum.all?(messages, fn m -> m.message_id == message_id end)

      definitions = Enum.map(messages, & &1.definition) |> Enum.sort()
      assert definitions == ["Hello", "Hola"]

      on_exit(fn ->
        I18nCache.delete("en")
        I18nCache.delete("es")
      end)
    end

    test "returns error when locale does not exist" do
      message_id = "test.message.error"
      langs = [{999_999, %{"definition" => "Test"}}]

      assert {:error, :not_found} = Messages.create_messages(message_id, langs)
    end

    test "caches messages in I18nCache" do
      locale1 = insert(:locale, lang: "en")
      locale2 = insert(:locale, lang: "es")

      message_id = "test.cache.multi"

      langs = [
        {locale1.id, %{"definition" => "Cached English"}},
        {locale2.id, %{"definition" => "Cached Spanish"}}
      ]

      {:ok, _} = Messages.create_messages(message_id, langs)

      assert I18nCache.get_definition("en", message_id) == "Cached English"
      assert I18nCache.get_definition("es", message_id) == "Cached Spanish"

      on_exit(fn ->
        I18nCache.delete("en")
        I18nCache.delete("es")
      end)
    end
  end

  describe "delete_deprecated_messages/2" do
    test "deletes messages matching message_ids" do
      message1 = insert(:message, message_id: "deprecated.message.1")
      message2 = insert(:message, message_id: "deprecated.message.2")
      message3 = insert(:message, message_id: "keep.message")

      Messages.delete_deprecated_messages(["deprecated.message.1", "deprecated.message.2"], [])

      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message1.id) end
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message2.id) end
      assert Messages.get_message!(message3.id)
    end

    test "deletes messages matching definitions" do
      message1 = insert(:message, definition: "Old Definition 1")
      message2 = insert(:message, definition: "Old Definition 2")
      message3 = insert(:message, definition: "Keep Definition")

      Messages.delete_deprecated_messages([], ["Old Definition 1", "Old Definition 2"])

      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message1.id) end
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message2.id) end
      assert Messages.get_message!(message3.id)
    end

    test "deletes messages matching either message_ids or definitions" do
      message1 = insert(:message, message_id: "deprecated.id", definition: "Keep Def")
      message2 = insert(:message, message_id: "keep.id", definition: "Deprecated Def")
      message3 = insert(:message, message_id: "keep.id2", definition: "Keep Def2")

      Messages.delete_deprecated_messages(["deprecated.id"], ["Deprecated Def"])

      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message1.id) end
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message2.id) end
      assert Messages.get_message!(message3.id)
    end

    test "returns ok when no messages match" do
      insert(:message, message_id: "keep.message", definition: "Keep Definition")

      assert :ok = Messages.delete_deprecated_messages(["nonexistent"], ["nonexistent"])
    end
  end
end
