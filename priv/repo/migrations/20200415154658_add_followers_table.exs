defmodule Twitter.Core.Repo.Migrations.AddFollowersTable do
  use Ecto.Migration

  def change do
    create table(:followers, primary_key: false) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:follower_id, references(:users, column: :id, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:followers, [:user_id, :follower_id]))
    create(index(:followers, [:user_id]))
    create(index(:followers, [:follower_id]))
  end
end
