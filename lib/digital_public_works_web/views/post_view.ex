defmodule DigitalPublicWorksWeb.PostView do
  use DigitalPublicWorksWeb, :view

  def format_date(datetime) do
    Timex.format!(datetime, "%B %-d, %Y", :strftime)
  end
end
