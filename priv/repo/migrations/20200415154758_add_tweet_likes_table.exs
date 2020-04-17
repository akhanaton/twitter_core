defmodule Twitter.Core.Repo.Migrations.AddLikedTweetsTable do
  use Ecto.Migration

  def change do
    create table(:liked_tweets, primary_key: false) do
      add(:tweet_id, references(:tweets, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:liked_tweets, [:user_id, :tweet_id]))
    create(index(:liked_tweets, [:user_id]))
  end
end
