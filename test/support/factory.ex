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
      project: build(:project)
    }
  end
end
