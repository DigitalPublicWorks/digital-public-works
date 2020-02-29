# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DigitalPublicWorks.Repo.insert!(%DigitalPublicWorks.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias DigitalPublicWorks.{Accounts, Projects, Posts, Repo}

{:ok, admin} = Accounts.create_user(%{email: "admin@example.com", password: "test1234"})

admin
|> Ecto.Changeset.change(%{is_admin: true})
|> Repo.update!()

{:ok, user} = Accounts.create_user(%{email: "user@example.com", password: "test1234"})

{:ok, project} =
  Projects.create_project(user, %{
    title: "Digital Public Works",
    body:
      "A web platform for connecting civic projects with volunteers and mentors. We are looking for someone who can help us develop a privacy policy and terms of service."
  })

project
|> Ecto.Changeset.change(%{is_featured: true, is_public: true})
|> Repo.update!()

Posts.create_post(%{
  project_id: project.id,
  user_id: user.id,
  title: "Project Updates and New UI",
  body:
    "We rolled out the ability to post project updates which is how you are seeing this message. We also cleaned up the UI by removing placeholder links and text and making it more consistent. We're working on the ability to follow projects. That way you can stay up to date with the projects you are most interested in. We are looking for someone who can help us develop a privacy policy and terms of service."
})
