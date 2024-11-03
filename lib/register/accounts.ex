defmodule Register.Accounts do
  use Ash.Domain,

  extensions: [AshAdmin.Domain]
  admin do
    show? true
  end

  resources do
    resource Register.Accounts.Token
    resource Register.Accounts.User
  end
end
