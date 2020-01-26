defmodule DigitalPublicWorksWeb.Permission do
  
  alias DigitalPublicWorks.Projects.Project
  alias DigitalPublicWorks.Posts.Post

  def can?(user, action, %Project{} = project) do
    cond do
      action in [:show, :index] -> true
      action in [:new, :create] -> user
      action in [:edit, :update, :delete] ->
        user && user.id == project.user_id || user.is_admin
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
