defmodule DigitalPublicWorksWeb.FormHelpers do
  @doc """
  Returns create_text if changeset is a new record or update_text if changeset is an existing record
  """
  def submit_text(%Ecto.Changeset{} = changeset, create_text \\ nil, update_text \\ nil) do
    model_name =
      changeset.data.__struct__
      |> Module.split()
      |> List.last()

    case Ecto.get_meta(changeset.data, :state) do
      :built -> create_text || "Create #{model_name}"
      :loaded -> update_text || "Update #{model_name}"
    end
  end
end
