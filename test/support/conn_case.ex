defmodule TdI18nWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use TdI18nWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  import TdI18n.Authentication, only: :functions

  using do
    quote do
      # Import conveniences for testing with connections
      import Assertions
      import Plug.Conn
      import Phoenix.ConnTest
      import TdI18n.Factory
      import TdI18nWeb.ConnCase

      alias TdI18nWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint TdI18nWeb.Endpoint
    end
  end

  setup tags do
    TdI18n.DataCase.setup_sandbox(tags)

    case tags[:authentication] do
      nil ->
        [conn: Phoenix.ConnTest.build_conn()]

      auth_opts ->
        auth_opts
        |> create_claims()
        |> create_user_auth_conn()
        |> assign_permissions(auth_opts[:permissions])
    end
  end
end
