defmodule Twitter.Core.Repo.Migrations.AddTweetsTable do
  use Ecto.Migration

  def change do
    create table(:tweets) do
      add(:content, :string, size: 140)
      add(:is_visible, :boolean, default: true)
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(index(:tweets, [:user_id]))
  end
end
