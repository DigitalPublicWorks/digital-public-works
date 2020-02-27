defmodule DigitalPublicWorksWeb.UserControllerTest do
  use DigitalPublicWorksWeb.ConnCase

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign Up"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: params_for(:user))

      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_flash(conn, :info) =~ "User created successfully"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: %{})
      assert html_response(conn, 200) =~ "Sign Up"
    end
  end

  describe "edit user" do
    @tag :as_user
    test "renders form for editing chosen user", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :edit))

      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    @tag :as_user
    test "redirects when data is valid", %{conn: conn} do
      new_email = "newemail@example.com"

      conn = put(conn, Routes.user_path(conn, :update), user: %{email: new_email})

      assert redirected_to(conn) == Routes.user_path(conn, :edit)
      assert get_flash(conn, :info) =~ "User updated successfully"
    end

    @tag :as_user
    test "renders errors when data is invalid", %{conn: conn} do
      conn = put(conn, Routes.user_path(conn, :update), user: %{email: nil})

      assert html_response(conn, 200) =~ "Edit User"
    end
  end
end
