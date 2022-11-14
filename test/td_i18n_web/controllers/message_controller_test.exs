defmodule TdI18nWeb.MessageControllerTest do
  use TdI18nWeb.ConnCase

  describe "GET /api/messages" do
    @tag authentication: [role: "admin"]
    test "lists all messages", %{conn: conn} do
      conn = get(conn, Routes.message_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "PUT /api/messages/:id" do
    setup :create_message

    @tag authentication: [role: "admin"]
    test "renders message when data is valid", %{conn: conn, message: %{id: id} = message} do
      params = string_params_for(:message)

      assert %{"data" => data} =
               conn
               |> put(Routes.message_path(conn, :update, message), message: params)
               |> json_response(:ok)

      assert %{"id" => ^id} = data

      assert %{"data" => data} =
               conn
               |> get(Routes.message_path(conn, :show, id))
               |> json_response(:ok)

      assert_maps_equal(data, params, ["description", "definition", "message_id"])
    end

    @tag authentication: [role: "admin"]
    test "renders errors when data is invalid", %{conn: conn, message: message} do
      params = %{"definition" => nil, "description" => nil, "message_id" => nil}

      assert %{"errors" => errors} =
               conn
               |> put(Routes.message_path(conn, :update, message), message: params)
               |> json_response(:unprocessable_entity)

      assert errors == %{
               "definition" => ["can't be blank"],
               "description" => ["can't be blank"],
               "message_id" => ["can't be blank"]
             }
    end
  end

  describe "DELETE /api/messages/:id" do
    setup :create_message

    @tag authentication: [role: "admin"]
    test "deletes chosen message", %{conn: conn, message: message} do
      assert conn
             |> delete(Routes.message_path(conn, :delete, message))
             |> response(:no_content)

      assert_error_sent :not_found, fn ->
        get(conn, Routes.message_path(conn, :show, message))
      end
    end
  end

  defp create_message(_) do
    [message: insert(:message)]
  end
end
