defmodule TdI18n.Repo.Migrations.RemoveDefaultFromLocales do
  use Ecto.Migration

  def change do
    alter table("locales") do
      remove :is_default, :string, null: false
    end
  end
end
