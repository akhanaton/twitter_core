defmodule Twitter.Core.Repo.Migrations.AddCommentLikesTable do
  use Ecto.Migration

  def change do
    create table(:comment_likes, primary_key: false) do
      add(:comment_id, references(:comments, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:comment_likes, [:user_id, :comment_id]))
    create(index(:comment_likes, [:user_id]))
  end
end
