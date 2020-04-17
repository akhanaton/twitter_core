defmodule Twitter.Core.Repo.Migrations.AddLikedCommentsTable do
  use Ecto.Migration

  def change do
    create table(:liked_comments, primary_key: false) do
      add(:comment_id, references(:comments, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:liked_comments, [:user_id, :comment_id]))
    create(index(:liked_comments, [:user_id]))
  end
end
