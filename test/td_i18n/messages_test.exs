defmodule TdI18n.MessagesTest do
  use TdI18n.DataCase

  alias TdI18n.Messages
  alias TdI18n.Messages.Message

  @invalid_attrs %{definition: nil, description: nil}

  describe "messages" do
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
      %{id: locale_id} = locale = insert(:locale)

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
    end

    test "create_message/1 with invalid data returns error changeset" do
      locale = insert(:locale)
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(locale, @invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = insert(:message)

      update_attrs = %{
        definition: "some updated definition",
        description: "some updated description"
      }

      assert {:ok, %Message{} = message} = Messages.update_message(message, update_attrs)
      assert message.definition == "some updated definition"
      assert message.description == "some updated description"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = insert(:message)
      assert {:error, %Ecto.Changeset{}} = Messages.update_message(message, @invalid_attrs)
    end

    test "delete_message/1 deletes the message" do
      message = insert(:message)
      assert {:ok, %Message{}} = Messages.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.id) end
    end
  end
end
