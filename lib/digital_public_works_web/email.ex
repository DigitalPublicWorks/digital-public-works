defmodule DigitalPublicWorksWeb.Email do
  use Bamboo.Phoenix, view: DigitalPublicWorksWeb.EmailView

  def welcome_email(user) do
    base_email()
    |> to(user)
    |> subject("Welcome!")
    |> render("welcome.text")
  end

  def password_reset(user) do
    base_email()
    |> assign(:reset_token, user.reset_token)
    |> to(user)
    |> subject("Reset Password")
    |> render("password_reset.text")
  end

  defp base_email do
    new_email()
    |> from("Digital Public Works <support@digitalpublicworks.com>")
  end
end
