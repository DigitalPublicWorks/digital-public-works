defmodule DigitalPublicWorks.Factory do
  use ExMachina.Ecto, repo: DigitalPublicWorks.Repo

  alias DigitalPublicWorks.Accounts.User
  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Posts.Post

  def user_factory do
    %User{
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "test1234"
    }
  end

  def reset_user_factory() do
    reset_sent_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    reset_token = DigitalPublicWorks.Accounts.generate_url_safe_token()

    struct!(
      user_factory(),
      %{reset_token: reset_token, reset_sent_at: reset_sent_at}
    )
  end

  def project_factory do
    %Project{
      title: sequence(:email, &"Project #{&1}"),
      body: "test description",
      user: build(:user)
    }
  end

  def post_factory do
    %Post{
      body: "test description",
      project: build(:project),
      user: build(:user)
    }
  end
end
