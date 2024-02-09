defmodule TdI18nWeb.LocaleControllerTest do
  use TdI18nWeb.ConnCase

  describe "GET /api/locales" do
    test "lists all locales without messages", %{conn: conn} do
      %{locale_id: locale_id} = insert(:message)

      assert %{"data" => [locale]} =
               conn
               |> get(Routes.locale_path(conn, :index), %{"includeMessages" => "false"})
               |> json_response(:ok)

      assert %{
               "id" => ^locale_id,
               "lang" => _,
               "is_default" => _,
               "is_required" => _,
               "is_enabled" => _,
               "name" => _,
               "local_name" => _
             } = locale

      refute Map.has_key?(locale, "messages")
    end
  end

  describe "POST /api/locales" do
    @tag authentication: [role: "admin"]
    test "renders locale when data is valid", %{conn: conn} do
      params = string_params_for(:locale)

      assert %{"data" => data} =
               conn
               |> post(Routes.locale_path(conn, :create), locale: params)
               |> json_response(:created)

      assert %{"id" => id} = data

      assert %{"data" => data} =
               conn
               |> get(Routes.locale_path(conn, :show, id))
               |> json_response(:ok)

      assert_maps_equal(data, params, ["lang"])
    end

    @tag authentication: [role: "admin"]
    test "renders multiple locale when data is valid", %{conn: conn} do
      params = [
        %{"lang" => "td", "name" => "Truedat", "local_name" => "Truedish"},
        %{"lang" => "bt", "name" => "Bluetab", "local_name" => "Bluetarian"}
      ]

      assert %{"data" => [locale | _]} =
               conn
               |> post(Routes.locale_path(conn, :create), locales: params)
               |> json_response(:created)

      assert %{
               "id" => _,
               "is_default" => false,
               "is_required" => false,
               "lang" => "td",
               "is_enabled" => false,
               "name" => "Truedat",
               "local_name" => "Truedish"
             } = locale
    end

    @tag authentication: [role: "admin"]
    test "renders errors when data is invalid", %{conn: conn} do
      params = %{"lang" => nil, "name" => nil, "local_name" => nil}

      assert %{"errors" => errors} =
               conn
               |> post(Routes.locale_path(conn, :create), locale: params)
               |> json_response(:unprocessable_entity)

      assert errors == %{
               "lang" => ["can't be blank"],
               "name" => ["can't be blank"],
               "local_name" => ["can't be blank"]
             }
    end

    @tag authentication: [role: "user"]
    test "responds forbidden when user is not admin", %{conn: conn} do
      assert %{"errors" => errors} =
               conn
               |> post(Routes.locale_path(conn, :create), locale: %{})
               |> json_response(:forbidden)

      assert errors == %{"detail" => "Forbidden"}
    end
  end

  describe "PATCH /api/locales/:id" do
    setup :create_locale

    @tag authentication: [role: "admin"]
    test "renders locale when data is valid", %{conn: conn, locale: %{id: id} = locale} do
      params =
        string_params_for(:locale)
        |> Map.put("messages", [string_params_for(:message, locale_id: id)])

      assert %{"data" => data} =
               conn
               |> patch(Routes.locale_path(conn, :update, locale), locale: params)
               |> json_response(:ok)

      assert %{"id" => ^id} = data

      assert %{"data" => data} =
               conn
               |> get(Routes.locale_path(conn, :show, id))
               |> json_response(:ok)

      assert_maps_equal(data, params, ["lang", "name", "local_name"])
    end

    @tag authentication: [role: "admin"]
    test "update is_enabled locale", %{
      conn: conn,
      locale: %{id: id, lang: lang} = locale
    } do
      assert %{"data" => data} =
               conn
               |> patch(Routes.locale_path(conn, :update, locale),
                 locale: %{
                   "is_enabled" => true,
                   "lang" => lang
                 }
               )
               |> json_response(:ok)

      assert %{"id" => ^id, "is_enabled" => true} = data
    end

    @tag authentication: [role: "admin"]
    test "renders errors when data is invalid", %{conn: conn, locale: locale} do
      params = %{"lang" => nil, "name" => nil, "local_name" => nil}

      assert %{"errors" => errors} =
               conn
               |> patch(Routes.locale_path(conn, :update, locale), locale: params)
               |> json_response(:unprocessable_entity)

      assert errors == %{
               "lang" => ["can't be blank"],
               "name" => ["can't be blank"],
               "local_name" => ["can't be blank"]
             }
    end

    @tag authentication: [role: "user"]
    test "responds forbidden when user is not admin", %{conn: conn, locale: locale} do
      assert %{"errors" => errors} =
               conn
               |> patch(Routes.locale_path(conn, :update, locale), locale: %{})
               |> json_response(:forbidden)

      assert errors == %{"detail" => "Forbidden"}
    end
  end

  describe "DELETE /api/locales/:id" do
    setup :create_locale

    @tag authentication: [role: "admin"]
    test "deletes chosen locale", %{conn: conn, locale: locale} do
      assert conn
             |> delete(Routes.locale_path(conn, :delete, locale))
             |> response(:no_content)

      assert_error_sent :not_found, fn ->
        get(conn, Routes.locale_path(conn, :show, locale))
      end
    end

    @tag authentication: [role: "user"]
    test "responds forbidden when user is not admin", %{conn: conn, locale: locale} do
      assert %{"errors" => errors} =
               conn
               |> delete(Routes.locale_path(conn, :delete, locale))
               |> json_response(:forbidden)

      assert errors == %{"detail" => "Forbidden"}
    end
  end

  defp create_locale(_) do
    %{locale: locale} = insert(:message)
    [locale: locale]
  end
end
