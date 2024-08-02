defmodule TdI18nWeb.LocaleMessageControllerTest do
  use TdI18nWeb.ConnCase

  describe "GET /api/locales/:locale_id/messages" do
    test "returns messages by locale id", %{conn: conn} do
      %{id: locale_id} = insert(:locale, is_default: true, is_required: true, is_enabled: true)
      %{message_id: message_id, definition: definition} = insert(:message, locale_id: locale_id)

      assert %{message_id => definition} ==
               conn
               |> get(Routes.locale_message_path(conn, :index, locale_id))
               |> json_response(:ok)
    end

    test "returns messages by lang", %{conn: conn} do
      locale = insert(:locale, is_default: true, is_enabled: true)

      %{locale: %{lang: lang}, message_id: message_id, definition: definition} =
        insert(:message, locale: locale)

      assert %{message_id => definition} ==
               conn
               |> get(Routes.locale_message_path(conn, :index, lang))
               |> json_response(:ok)
    end
  end

  describe "POST /api/locales/:locale_id/messages" do
    @tag authentication: [role: "admin"]
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

    @tag authentication: [role: "admin"]
    test "renders errors when data is invalid", %{conn: conn} do
      %{id: locale_id} = insert(:locale)

      params = %{"definition" => nil, "description" => nil, "message_id" => nil}

      assert %{"errors" => errors} =
               conn
               |> post(Routes.locale_message_path(conn, :create, locale_id), message: params)
               |> json_response(:unprocessable_entity)

      assert errors == %{
               "definition" => ["can't be blank"],
               "message_id" => ["can't be blank"]
             }
    end
  end
end
