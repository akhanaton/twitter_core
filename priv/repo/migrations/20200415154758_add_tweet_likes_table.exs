defmodule Twitter.Core.Repo.Migrations.AddTweetLikesTable do
  use Ecto.Migration

  def change do
    create table(:tweet_likes, primary_key: false) do
      add(:tweet_id, references(:tweets, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:tweet_likes, [:user_id, :tweet_id]))
    create(index(:tweet_likes, [:user_id]))
  end
end
