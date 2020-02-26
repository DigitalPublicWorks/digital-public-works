defmodule DigitalPublicWorks.PostsTest do
  use DigitalPublicWorks.DataCase

  alias DigitalPublicWorks.Posts

  describe "post" do
    alias DigitalPublicWorks.Posts.Post

    @valid_attrs %{title: "some title", body: "some body"}
    @update_attrs %{title: "some updated title", body: "some updated body"}
    @invalid_attrs %{title: nil, body: nil}

    def post_fixture() do
      Posts.get_post!(insert(:post).id)
    end

    test "list_post/0 returns all post" do
      post =
        post_fixture()
        |> Repo.preload([:project, :user])
      assert Posts.list_posts(post.project) == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      project = insert(:project)
      user = insert(:user)

      assert {:ok, %Post{} = post} =
               Posts.create_post(Map.merge(@valid_attrs, %{user_id: user.id, project_id: project.id}))

      assert post.body == "some body"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Posts.update_post(post, @update_attrs)
      assert post.body == "some updated body"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
