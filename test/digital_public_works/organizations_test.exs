defmodule DigitalPublicWorks.OrganizationsTest do
  use DigitalPublicWorks.DataCase

  alias DigitalPublicWorks.Organizations

  describe "organizations" do
    alias DigitalPublicWorks.Organizations.Organization

    @valid_attrs %{description: "some description", name: "some name", slug: "some slug"}
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      slug: "some updated slug"
    }
    @invalid_attrs %{description: nil, name: nil, slug: nil}

    def organization_fixture(attrs \\ %{}) do
      {:ok, organization} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Organizations.create_organization()

      organization
    end

    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Organizations.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Organizations.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      assert {:ok, %Organization{} = organization} =
               Organizations.create_organization(@valid_attrs)

      assert organization.description == "some description"
      assert organization.name == "some name"
      assert organization.slug == "some slug"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()

      assert {:ok, %Organization{} = organization} =
               Organizations.update_organization(organization, @update_attrs)

      assert organization.description == "some updated description"
      assert organization.name == "some updated name"
      assert organization.slug == "some updated slug"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Organizations.update_organization(organization, @invalid_attrs)

      assert organization == Organizations.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Organizations.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Organizations.change_organization(organization)
    end

    test "get_organization_by_slug/1 returns a organization" do
      organization = organization_fixture()
      assert organization == Organizations.get_organization_by_slug(organization.slug)
    end

    test "can add and remove users from organization" do
      organization = organization_fixture()
      user = insert(:user).id |> DigitalPublicWorks.Accounts.get_user!()

      assert organization |> Ecto.assoc(:users) |> Repo.all() == []
      refute Organizations.is_user?(organization, user)

      Organizations.add_user(organization, user)
      assert organization |> Ecto.assoc(:users) |> Repo.all() == [user]
      assert Organizations.is_user?(organization, user)

      Organizations.remove_user(organization, user)
      assert organization |> Ecto.assoc(:users) |> Repo.all() == []
      refute Organizations.is_user?(organization, user)
    end

    test "can add and remove projects from organization" do
      organization = organization_fixture()
      project = insert(:project).id |> DigitalPublicWorks.Projects.get_project!()

      assert organization |> Ecto.assoc(:projects) |> Repo.all() == []
      refute Organizations.is_project?(organization, project)

      Organizations.add_project(organization, project)

      assert organization |> Ecto.assoc(:projects) |> Repo.all() |> Repo.preload(:user) == [
               project
             ]

      assert Organizations.is_project?(organization, project)

      Organizations.remove_project(organization, project)
      assert organization |> Ecto.assoc(:projects) |> Repo.all() == []
      refute Organizations.is_project?(organization, project)
    end
  end
end
