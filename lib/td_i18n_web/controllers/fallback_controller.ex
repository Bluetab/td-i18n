defmodule TdI18nWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use TdI18nWeb, :controller

  alias TdI18nWeb.ChangesetView
  alias TdI18nWeb.ErrorView

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}), do: render_error(conn, :not_found, "404.json")
  def call(conn, {:error, :forbidden}), do: render_error(conn, :forbidden, "403.json")

  def call(conn, {:error, :unprocessable_entity}),
    do: render_error(conn, :unprocessable_entity, "422.json")

  defp render_error(conn, status, template) do
    conn
    |> put_status(status)
    |> put_view(ErrorView)
    |> render(template)
  end
end
