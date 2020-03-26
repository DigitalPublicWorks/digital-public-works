defmodule DigitalPublicWorks.Factory do
  use ExMachina.Ecto, repo: DigitalPublicWorks.Repo

  alias DigitalPublicWorks.Accounts.User
  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Posts.Post
  alias DigitalPublicWorks.Invites.ProjectInvite

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
      project: build(:project),
      user: build(:user)
    }
  end

  def project_invite_factory do
    %ProjectInvite{
      email: sequence(:email, &"email-#{&1}@example.com"),
      project: build(:project)
    }
  end

  def organization_factory do
    %DigitalPublicWorks.Organizations.Organization{
      name: sequence(:name, &"Organization #{&1}"),
      description: "Test organization description",
      slug: sequence(:slug, &"organization-#{&1}")
    }
  end
end
