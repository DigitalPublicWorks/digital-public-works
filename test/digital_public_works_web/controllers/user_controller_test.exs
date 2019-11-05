defmodule DigitalPublicWorksWeb.UserControllerTest do
  use DigitalPublicWorksWeb.ConnCase

  alias DigitalPublicWorks.Accounts

  @create_attrs %{email: "some email", password: "some password"}
  @update_attrs %{email: "some updated email", password: "some updated password"}
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert redirected_to(conn) == Routes.user_path(conn, :show)

      conn = get(conn, Routes.user_path(conn, :show))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> get(Routes.user_path(conn, :edit))

      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> put(Routes.user_path(conn, :update), user: @update_attrs)

      assert redirected_to(conn) == Routes.user_path(conn, :show)

      conn = get(conn, Routes.user_path(conn, :show))
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
      |> Plug.Conn.assign(:current_user, user)
      |> put(Routes.user_path(conn, :update), user: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
