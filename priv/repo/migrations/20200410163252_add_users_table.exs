defmodule Twitter.Core.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string, size: 40)
      add(:name, :string, size: 60)
      add(:username, :citext)
      add(:password_hash, :string)

      timestamps()
    end

    create(unique_index(:users, [:email]))
    create(unique_index(:users, [:username]))
  end
end
