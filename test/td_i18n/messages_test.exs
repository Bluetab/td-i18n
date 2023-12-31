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
end
