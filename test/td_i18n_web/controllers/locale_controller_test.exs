defmodule TdI18nWeb.LocaleControllerTest do
  use TdI18nWeb.ConnCase

  describe "GET /api/locales" do
    test "lists all locales", %{conn: conn} do
      %{locale_id: locale_id, id: id} = insert(:message)

      assert %{"data" => data} =
               conn
               |> get(Routes.locale_path(conn, :index))
               |> json_response(:ok)

      assert [locale] = data

      assert %{
               "id" => ^locale_id,
               "is_default" => _,
               "lang" => _,
               "messages" => [%{"id" => ^id, "definition" => _, "description" => _}]
             } = locale
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

      assert_maps_equal(data, params, ["is_default", "lang"])
    end

    @tag authentication: [role: "admin"]
    test "renders errors when data is invalid", %{conn: conn} do
      params = %{"lang" => nil, "is_default" => nil}

      assert %{"errors" => errors} =
               conn
               |> post(Routes.locale_path(conn, :create), locale: params)
               |> json_response(:unprocessable_entity)

      assert errors == %{"is_default" => ["can't be blank"], "lang" => ["can't be blank"]}
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

      assert_maps_equal(data, params, ["is_default", "lang"])
    end

    @tag authentication: [role: "admin"]
    test "renders errors when data is invalid", %{conn: conn, locale: locale} do
      params = %{"lang" => nil, "is_default" => nil}

      assert %{"errors" => errors} =
               conn
               |> patch(Routes.locale_path(conn, :update, locale), locale: params)
               |> json_response(:unprocessable_entity)

      assert errors == %{"is_default" => ["can't be blank"], "lang" => ["can't be blank"]}
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
