defmodule Register.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Register.Accounts.User, _opts) do
    Application.fetch_env(:register, :token_signing_secret)
  end
end
