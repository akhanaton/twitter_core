defmodule Twitter.Core.Repo.Migrations.AddTweetsTable do
  use Ecto.Migration

  def change do
    create table(:tweets) do
      add(:content, :string, size: 140, null: false)
      add(:is_visible, :boolean, default: true, null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:tweets, [:user_id]))
  end
end
