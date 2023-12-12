defmodule TdI18nWeb.AllLocaleControllerTest do
  use TdI18nWeb.ConnCase

  describe "GET /api/locales/all_locales" do
    @tag authentication: [role: "admin"]
    test "lists all avaliable locales", %{conn: conn} do
      insert(:all_locale)

      assert %{"data" => data} =
               conn
               |> get(Routes.all_locale_path(conn, :index))
               |> json_response(:ok)

      assert [%{"code" => _, "name" => _, "local" => _}] = data
    end
  end
end
