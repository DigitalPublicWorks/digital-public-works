defmodule DigitalPublicWorksWeb.PasswordResetControllerTest do
  use DigitalPublicWorksWeb.ConnCase

  test "shows forgot password screen", %{conn: conn} do
    conn = get(conn, Routes.password_reset_path(conn, :new))
    assert html_response(conn, 200) =~ "Reset Password"
  end

  test "show error when attempting to reset missing email", %{conn: conn} do
    conn = post(conn, Routes.password_reset_path(conn, :create, %{email: "1234"}))
    assert get_flash(conn, :error) =~ "Account not found"
  end

  test "creates password reset", %{conn: conn} do
    user = insert(:user)

    conn = post(conn, Routes.password_reset_path(conn, :create, %{email: user.email}))
    assert get_flash(conn, :info) =~ "Password reset email sent to #{user.email}"

    user
    |> Map.get(:id)
    |> DigitalPublicWorks.Accounts.get_user!()
    |> DigitalPublicWorksWeb.Email.password_reset()
    |> assert_delivered_email()
  end

  test "show update password screen", %{conn: conn} do
    user = insert(:reset_user)
    conn = get(conn, Routes.password_reset_path(conn, :edit, user.reset_token))
    assert html_response(conn, 200) =~ "Update Password"
  end

  test "show error when user is trying to access password update screen with invalid token", %{conn: conn} do
    conn = get(conn, Routes.password_reset_path(conn, :edit, "1234"))
    assert get_flash(conn, :error) =~ "Invalid password reset token"
  end

  test "update password via password reset", %{conn: conn} do
    user = insert(:reset_user)
    new_password = "newpassword"

    conn = post(conn, Routes.password_reset_path(conn, :update, user.reset_token, %{password: new_password}))
    assert get_flash(conn, :info) =~ "Password reset successfully"
  end
end
