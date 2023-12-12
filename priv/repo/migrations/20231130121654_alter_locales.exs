defmodule TdI18n.Repo.Migrations.AlterLocales do
  use Ecto.Migration

  def change do
    alter table(:locales) do
      add :is_default, :boolean, default: false
      add :is_required, :boolean, default: false
    end
  end
end
