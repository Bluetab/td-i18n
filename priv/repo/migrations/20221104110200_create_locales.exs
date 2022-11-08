defmodule TdI18n.Repo.Migrations.CreateLocales do
  use Ecto.Migration

  def change do
    create table(:locales) do
      add :lang, :string, null: false
      add :is_default, :boolean, default: false, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
