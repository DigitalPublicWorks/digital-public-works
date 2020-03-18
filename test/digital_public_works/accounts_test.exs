defmodule DigitalPublicWorks.AccountsTest do
  use DigitalPublicWorks.DataCase

  alias DigitalPublicWorks.Accounts
  alias DigitalPublicWorks.Accounts.User

  describe "users" do
    @valid_attrs %{email: "some email", password: "some password"}
    @update_attrs %{email: "some updated email", password: "some updated password"}
    @invalid_attrs %{email: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.password_hash != nil
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "password_resets" do
    def password_reset_fixture(attrs \\ %{}) do
      insert(:reset_user, attrs) |> Map.get(:id) |> Accounts.get_user!()
    end

    test "get_password_reset!/1 returns the password_reset with given reset_token" do
      user = password_reset_fixture()
      assert Accounts.get_password_reset!(user.reset_token) == user
    end

    test "get_password_reset!/1 raise exception when reset_token is nil" do
      user = insert(:user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_password_reset!(user.reset_token) end
    end

    test "create_password_reset/1 with valid data creates a password_reset" do
      assert {:ok, %User{} = user} = Accounts.create_password_reset(insert(:user))
      refute user.reset_token |> is_nil()
      refute user.reset_sent_at |> is_nil()
    end

    test "update_password_reset/2 with valid data updates the user password and deletes password reset" do
      user = password_reset_fixture()
      new_password = "newpassword"

      assert {:ok, %User{} = user} =
               Accounts.update_password_reset(user, %{"password" => new_password})

      assert {:ok, _user} =
               Accounts.verify_user(%{"email" => user.email, "password" => new_password})

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_password_reset!(user.reset_token) end
    end

    test "update_password_reset/2 with expired invite returns error" do
      expired_time =
        NaiveDateTime.utc_now()
        |> Timex.shift(minutes: -11)
        |> NaiveDateTime.truncate(:second)

      user = password_reset_fixture(reset_sent_at: expired_time)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_password_reset(user, %{"password" => "doesntmatter"})

      assert Accounts.get_password_reset!(user.reset_token) == user
    end

    test "delete_password_reset/1 deletes the password_reset" do
      user = password_reset_fixture()
      assert {:ok, %User{} = user} = Accounts.delete_password_reset(user)
      assert is_nil(user.reset_token)
      assert is_nil(user.reset_sent_at)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_password_reset!(user.reset_token)
      end
    end
  end
end
