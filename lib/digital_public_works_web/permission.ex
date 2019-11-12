defmodule DigitalPublicWorksWeb.Permission do
  
  alias DigitalPublicWorks.Projects.Project

  def can?(user, action, %Project{} = project) do
    cond do
      action in [:show, :index] -> true
      action in [:new, :create] -> user
      action in [:edit, :update, :delete] -> user && user.id == project.user_id
      true -> false
    end
  end

end