defmodule DigitalPublicWorksWeb.PasswordResetController do
  use DigitalPublicWorksWeb, :controller
  alias DigitalPublicWorks.Accounts

  plug :get_user

  defp get_user(%{params: %{"reset_token" => reset_token}} = conn, _args) do
    conn
    |> assign(:user, Accounts.get_password_reset!(reset_token))
  rescue
    _ ->
      conn
      |> put_flash(:error, "Invalid password reset token")
      |> redirect(to: Routes.password_reset_path(conn, :new))
      |> halt()
  end

  defp get_user(conn, _args), do: conn

  def new(conn, _args) do
    conn
    |> render("new.html")
  end

  def create(conn, %{"email" => email}) do
    case Accounts.get_user_by(%{"email" => email}) do
      nil ->
        conn
        |> put_flash(:error, "Account not found")
        |> render("new.html")

      user ->
        {:ok, user} = Accounts.create_password_reset(user)

        user
        |> DigitalPublicWorksWeb.Email.password_reset()
        |> DigitalPublicWorksWeb.Mailer.deliver_now()

        conn
        |> put_flash(:info, "Password reset email sent to #{email}")
        |> render("new.html")
    end
  end

  def edit(conn, _params) do
    conn
    |> render("edit.html")
  end

  def update(%{assigns: %{user: user}} = conn, %{"password" => password}) do
    case Accounts.update_password_reset(user, %{"password" => password}) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> configure_session(renew: true)
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error updating password")
        |> render("edit.html")
    end
  end
end
