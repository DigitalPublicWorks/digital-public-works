defmodule DigitalPublicWorksWeb.Permission do

  alias DigitalPublicWorks.Projects
  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Posts.Post
  alias DigitalPublicWorks.Invites.ProjectInvite

  def can?(user, action, %Project{} = project) do
    cond do
      action in [:show, :index] -> true
      action in [:new, :create] -> user
      action in [:edit, :update, :delete, :remove_user] ->
        user && user.id == project.user_id
      action in [:publish] ->
        user && user.is_admin && !project.is_public
      action in [:unpublish] ->
        user && user.is_admin && project.is_public
      action in [:follow] ->
        user && user.id != project.user_id && !Projects.is_follower?(project, user) && !Projects.is_user?(project, user)
      action in [:unfollow] ->
        user && user.id != project.user_id && Projects.is_follower?(project, user) && !Projects.is_user?(project, user)
      action in [:leave] ->
        user && Projects.is_user?(project, user)
      true -> false
    end
  end

  def can?(user, action, %Post{} = post) do
    cond do
      action in [:show, :index] -> true
      action in [:new, :create] ->
        can?(user, :edit, post.project) || Projects.is_user?(post.project, user)
      action in [:edit, :update, :delete] ->
        can?(user, :edit, post.project) || (user && post.user_id == user.id)
      true -> false
    end
  end

  def can?(user, action, %ProjectInvite{} = project_invite) do
    cond do
      action in [:show, :update] -> user
      action in [:index, :create, :delete] -> can?(user, :edit, project_invite.project)
      true -> false
    end
  end

  alias DigitalPublicWorks.{Organizations, Organizations.Organization}
  def can?(user, action, %Organization{} = organization) do
    cond do
      action in [:show] -> true
      action in [:add_project, :remove_project] ->
        user && Organizations.is_user?(organization, user)
    end
  end

end
