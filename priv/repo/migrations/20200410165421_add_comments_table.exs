defmodule Twitter.Core.Repo.Migrations.AddCommentsTable do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add(:text, :string, size: 140)
      add(:is_visible, :boolean, default: true)
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:tweet_id, references(:tweets, on_delete: :delete_all))

      timestamps()
    end

    create(index(:comments, [:tweet_id]))
  end
end
