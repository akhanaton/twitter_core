defmodule Twitter.Core.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string, size: 40, null: false)
      add(:name, :string, size: 60, null: false)
      add(:username, :citext, null: false)
      add(:password_hash, :string, null: false)

      timestamps()
    end

    create(unique_index(:users, [:email]))
    create(unique_index(:users, [:username]))
  end
end
