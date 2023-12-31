defmodule TdI18n.Auth.Pipeline.Secure do
  @moduledoc """
  Plug pipeline for routes requiring authentication
  """

  use Guardian.Plug.Pipeline,
    otp_app: :td_i18n,
    error_handler: TdI18n.Auth.ErrorHandler,
    module: TdI18n.Auth.Guardian

  plug Guardian.Plug.VerifyHeader, claims: %{"aud" => "truedat", "iss" => "tdauth"}
  plug Guardian.Plug.LoadResource
  plug TdI18n.Auth.Plug.SessionExists
  plug TdI18n.Auth.Plug.CurrentResource
end
