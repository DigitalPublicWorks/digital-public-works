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

  def has_content?(str) do
    str != nil and String.trim(str) != ""
  end

  def render_meta(conn) do
    conn.assigns
    |> Map.get(:meta, %{})  # Default to empty struct in case :meta was deleted off the conn
    |> Map.drop([:title])   # Don't render the non-meta tag types
    |> Map.keys()
    |> Enum.map(&meta_tag(conn, &1))
  end

  def meta_tag(conn, :title) do
    content_tag(:title, fetch_meta_value(conn, :title))
  end

  def meta_tag(conn, key) 
      when key in [:author, :generator, :keywords, :viewport, :description, :"application-name"] do
    tag(
      :meta,
      name: key,
      content: fetch_meta_value(conn, key)
    )
  end

  def meta_tag(conn, key) do
    tag(
      :meta, 
      property: key, 
      content: fetch_meta_value(conn, key)
    )
  end

  defp fetch_meta_value(conn, key) do
    get_in(conn.assigns, [:meta, key])
  end

end
