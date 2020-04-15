defmodule Twitter.Core.Repo.Migrations.AddFollowersTable do
  use Ecto.Migration

  def change do
    create table(:followers, primary_key: false) do
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:follower_id, references(:users, column: :id, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:followers, [:user_id, :follower_id]))
    create(index(:followers, [:user_id]))
  end
end
