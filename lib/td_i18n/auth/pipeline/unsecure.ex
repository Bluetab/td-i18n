defmodule TdI18n.Auth.Pipeline.Unsecure do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :td_i18n,
    error_handler: TdI18n.Auth.ErrorHandler,
    module: TdI18n.Auth.Guardian

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.LoadResource, allow_blank: true
end
