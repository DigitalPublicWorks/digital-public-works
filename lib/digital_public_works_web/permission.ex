defmodule DigitalPublicWorksWeb.Permission do

  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Posts.Post

  def can?(user, action, %Project{} = project) do
    cond do
      action in [:show, :index] -> true
      action in [:new, :create] -> user
      action in [:edit, :update, :delete] ->
        user && user.id == project.user_id
      action in [:publish] ->
        user && user.is_admin && !project.is_public
      action in [:unpublish] ->
        user && user.is_admin && project.is_public
      true -> false
    end
  end

  def can?(user, action, %Post{} = post) do
    cond do
      action in [:show, :index] -> true
      action in [:new, :create, :edit, :update, :delete] -> can?(user, :edit, post.project)
      true -> false
    end
  end

end
