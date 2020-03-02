defmodule DigitalPublicWorksWeb.HTMLHelpers do
  use Phoenix.HTML
  alias Phoenix.HTML.Form

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
end
