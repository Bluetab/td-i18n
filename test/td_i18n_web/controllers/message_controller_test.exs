defmodule TdI18nWeb.MessageControllerTest do
  use TdI18nWeb.ConnCase

  describe "GET /api/messages" do
    @tag authentication: [role: "admin"]
    test "lists all messages", %{conn: conn} do
      conn = get(conn, Routes.message_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "POST /api/messages" do
    @tag authentication: [role: "admin"]
    test "renders message when data is valid", %{conn: conn} do
      %{id: locale_id1} = insert(:locale)
      %{id: locale_id2} = insert(:locale)
      %{"message_id" => message_id} = message1 = string_params_for(:message)
      message2 = string_params_for(:message)

      langs =
        %{}
        |> Map.put(
          Integer.to_string(locale_id1),
          Map.take(message1, ["definition", "description"])
        )
        |> Map.put(
          Integer.to_string(locale_id2),
          Map.take(message2, ["definition", "description"])
        )

      params = %{"message_id" => message_id, "langs" => langs}

      assert %{"data" => data} =
               conn
               |> post(Routes.message_path(conn, :create), message: params)
               |> json_response(:created)

      assert [
               %{
                 "message_id" => ^message_id,
                 "locale_id" => ^locale_id1
               },
               %{
                 "message_id" => ^message_id,
                 "locale_id" => ^locale_id2
               }
             ] = data
    end

    @tag authentication: [role: "admin"]
    test "renders error when creating duplicated message", %{conn: conn} do
      %{message_id: existing_message_id, locale_id: locale_id} = insert(:message)

      message = string_params_for(:message)

      params = %{
        "message_id" => existing_message_id,
        "langs" => %{
          Integer.to_string(locale_id) => Map.take(message, ["definition", "description"])
        }
      }

      assert %{"errors" => %{"locale_id" => ["has already been taken"]}} =
               conn
               |> post(Routes.message_path(conn, :create), message: params)
               |> json_response(:unprocessable_entity)
    end

    @tag authentication: [role: "admin"]
    test "renders error when locale is invalid", %{conn: conn} do
      %{"message_id" => message_id} = message = string_params_for(:message)

      params = %{
        "message_id" => message_id,
        "langs" => %{
          "0" => Map.take(message, ["definition", "description"])
        }
      }

      assert %{"errors" => %{"detail" => "Not Found"}} =
               conn
               |> post(Routes.message_path(conn, :create), message: params)
               |> json_response(:not_found)
    end

    @tag authentication: [role: "admin"]
    test "renders error when data in invalid", %{conn: conn} do
      %{id: locale_id} = insert(:locale)
      %{"message_id" => message_id} = string_params_for(:message)

      invalid_params = %{"definition" => nil, "description" => nil}

      params = %{
        "message_id" => message_id,
        "langs" => %{
          Integer.to_string(locale_id) => invalid_params
        }
      }

      assert %{"errors" => %{"definition" => ["can't be blank"]}} =
               conn
               |> post(Routes.message_path(conn, :create), message: params)
               |> json_response(:unprocessable_entity)
    end

    @tag authentication: [user_name: "non_admin"]
    test "renders forbidden if not admin", %{conn: conn} do
      %{id: locale_id} = insert(:locale)
      %{"message_id" => message_id} = message = string_params_for(:message)

      params = %{
        "message_id" => message_id,
        "langs" => %{
          Integer.to_string(locale_id) => Map.take(message, ["definition", "description"])
        }
      }

      assert %{"errors" => %{"detail" => "Forbidden"}} =
               conn
               |> post(Routes.message_path(conn, :create), message: params)
               |> json_response(:forbidden)
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
