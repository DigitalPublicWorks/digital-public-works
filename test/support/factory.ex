defmodule DigitalPublicWorks.Factory do
  use ExMachina.Ecto, repo: DigitalPublicWorks.Repo

  alias DigitalPublicWorks.Accounts.User

  def user_factory do
    %User{
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "test1234"
    }
  end
end
