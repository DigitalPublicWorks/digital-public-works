defmodule DigitalPublicWorksWeb.Email do
  use Bamboo.Phoenix, view: DigitalPublicWorksWeb.EmailView

  def welcome_email(user) do
    base_email()
    |> to(user)
    |> subject("Welcome!")
    |> render("welcome.text")
  end

  def project_invite_email(project_invite) do
    base_email()
    |> to(project_invite)
    |> assign(:project_invite, project_invite)
    |> assign(:project, project_invite.project)
    |> subject("Invited to Digital Public Works")
    |> render("project_invite.text")
  end

  defp base_email do
    new_email()
    |> from("Digital Public Works <support@digitalpublicworks.com>")
  end
end
