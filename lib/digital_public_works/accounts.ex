defmodule DigitalPublicWorks.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias DigitalPublicWorks.Repo

  alias DigitalPublicWorks.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def get_user_by(%{"email" => email}) do
    User
    |> Repo.get_by(email: email)
  end

  def verify_user(%{"password" => password} = params) do
    params
    |> get_user_by()
    |> Argon2.check_pass(password)
  end

  def find_or_create_by_email(email) do
    case get_user_by(%{"email" => email}) do
      nil ->
        length = 32
        password = :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
        create_user(%{email: email, password: password})

      user ->
        {:ok, user}
    end
  end

  # Password Reset

  def get_password_reset!(nil), do: raise Ecto.NoResultsError, queryable: User

  def get_password_reset!(reset_token) do
    from(u in User, where: [reset_token: ^reset_token])
    |> Repo.one!()
  end

  def create_password_reset(%User{} = user) do
    user
    |> Ecto.Changeset.change(%{
      reset_token: generate_url_safe_token(),
      reset_sent_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    })
    |> Repo.update()
  end

  def generate_url_safe_token(length \\ 16) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  def update_password_reset(%User{reset_token: reset_token} = user, _args)
      when is_nil(reset_token) do
    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:inserted_at, "Password reset not initiated")
  end

  def update_password_reset(%User{} = user, %{"password" => password}) do
    expires_at = Timex.shift(user.reset_sent_at, minutes: 10)

    case NaiveDateTime.compare(NaiveDateTime.utc_now(), expires_at) do
      :lt ->
        with {:ok, user} <- update_user(user, %{"password" => password}),
             do: user |> delete_password_reset()

      _ ->
        changeset =
          user
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.add_error(:inserted_at, "Password reset has expired")

        {:error, changeset}
    end
  end

  def delete_password_reset(%User{} = user) do
    user
    |> Ecto.Changeset.change(%{reset_token: nil, reset_sent_at: nil})
    |> Repo.update()
  end
end
