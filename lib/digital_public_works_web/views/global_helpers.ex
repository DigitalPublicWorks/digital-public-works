defmodule DigitalPublicWorksWeb.GlobalHelpers do
  use Phoenix.HTML
  alias Phoenix.HTML.Form

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

  def trix_content(content) do
    content_tag(:div, raw(content), class: "trix-content")
  end

  def trix_editor(f, field, opts \\ %{}) do
    content_tag :div, class: "form-group" do
      [
        hidden_input(f, field),
        content_tag(:label, get_in(opts, [:label, :text]) || Form.humanize(field), class: "col-form-label"),
        content_tag(:"trix-editor", nil, input: Form.input_id(f, field), class: "trix-content")
      ]
    end
  end

  def user_name(obj) do
    obj.user.display_name || "Project Member"
  end
end
