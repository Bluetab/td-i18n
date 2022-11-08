defmodule TdI18nWeb.LocaleMessageControllerTest do
  use TdI18nWeb.ConnCase

  alias TdI18n.Messages.Message

  @update_attrs %{
    definition: "some updated definition",
    description: "some updated description"
  }
  @invalid_attrs %{definition: nil, description: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all messages", %{conn: conn} do
      conn = get(conn, Routes.message_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create message" do
    test "renders message when data is valid", %{conn: conn} do
      %{id: locale_id} = insert(:locale)

      params = string_params_for(:message)

      assert %{"data" => %{"id" => id}} =
               conn
               |> post(Routes.locale_message_path(conn, :create, locale_id), message: params)
               |> json_response(:created)

      assert %{"data" => data} =
               conn
               |> get(Routes.message_path(conn, :show, id))
               |> json_response(:ok)

      assert data["locale_id"] == locale_id
      assert_maps_equal(data, params, ["message_id", "definition", "description"])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{id: locale_id} = insert(:locale)

      conn =
        post(conn, Routes.locale_message_path(conn, :create, locale_id), message: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update message" do
    setup [:create_message]

    test "renders message when data is valid", %{conn: conn, message: %Message{id: id} = message} do
      conn = put(conn, Routes.message_path(conn, :update, message), message: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.message_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "definition" => "some updated definition",
               "description" => "some updated description"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, message: message} do
      conn = put(conn, Routes.message_path(conn, :update, message), message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete message" do
    setup [:create_message]

    test "deletes chosen message", %{conn: conn, message: message} do
      conn = delete(conn, Routes.message_path(conn, :delete, message))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.message_path(conn, :show, message))
      end
    end
  end

  defp create_message(_) do
    message = insert(:message)
    [message: message]
  end
end
