defmodule TdI18nWeb.LocaleControllerTest do
  use TdI18nWeb.ConnCase

  import TdI18n.LocalesFixtures

  alias TdI18n.Locales.Locale

  @create_attrs %{
    is_default: true,
    lang: "some lang"
  }
  @update_attrs %{
    is_default: false,
    lang: "some updated lang"
  }
  @invalid_attrs %{is_default: nil, lang: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all locales", %{conn: conn} do
      conn = get(conn, Routes.locale_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create locale" do
    test "renders locale when data is valid", %{conn: conn} do
      conn = post(conn, Routes.locale_path(conn, :create), locale: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.locale_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "is_default" => true,
               "lang" => "some lang"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.locale_path(conn, :create), locale: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update locale" do
    setup [:create_locale]

    test "renders locale when data is valid", %{conn: conn, locale: %Locale{id: id} = locale} do
      conn = put(conn, Routes.locale_path(conn, :update, locale), locale: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.locale_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "is_default" => false,
               "lang" => "some updated lang"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, locale: locale} do
      conn = put(conn, Routes.locale_path(conn, :update, locale), locale: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete locale" do
    setup [:create_locale]

    test "deletes chosen locale", %{conn: conn, locale: locale} do
      conn = delete(conn, Routes.locale_path(conn, :delete, locale))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.locale_path(conn, :show, locale))
      end
    end
  end

  defp create_locale(_) do
    locale = locale_fixture()
    %{locale: locale}
  end
end
