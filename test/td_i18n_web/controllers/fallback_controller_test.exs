defmodule TdI18nWeb.FallbackControllerTest do
  use TdI18nWeb.ConnCase

  alias TdI18nWeb.FallbackController

  describe "call/2 with changeset error" do
    test "renders changeset errors", %{conn: conn} do
      changeset = %Ecto.Changeset{
        action: :insert,
        changes: %{},
        errors: [name: {"can't be blank", [validation: :required]}],
        data: %{},
        valid?: false
      }

      conn = FallbackController.call(conn, {:error, changeset})

      assert conn.status == 422
      assert %{"errors" => _} = json_response(conn, 422)
    end

    test "sets unprocessable_entity status for changeset errors", %{conn: conn} do
      changeset = %Ecto.Changeset{
        action: :update,
        changes: %{},
        errors: [field: {"is invalid", []}],
        data: %{},
        valid?: false
      }

      conn = FallbackController.call(conn, {:error, changeset})

      assert conn.status == 422
    end
  end

  describe "call/2 with not_found error" do
    test "renders 404 error", %{conn: conn} do
      conn = FallbackController.call(conn, {:error, :not_found})

      assert conn.status == 404
      assert json_response(conn, 404)
    end
  end

  describe "call/2 with forbidden error" do
    test "renders 403 error", %{conn: conn} do
      conn = FallbackController.call(conn, {:error, :forbidden})

      assert conn.status == 403
      assert json_response(conn, 403)
    end
  end

  describe "call/2 with unprocessable_entity error" do
    test "renders 422 error", %{conn: conn} do
      conn = FallbackController.call(conn, {:error, :unprocessable_entity})

      assert conn.status == 422
      assert json_response(conn, 422)
    end
  end
end
