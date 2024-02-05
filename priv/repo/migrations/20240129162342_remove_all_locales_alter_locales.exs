defmodule TdI18n.Repo.Migrations.RemoveAllLocalesAlterLocales do
  use Ecto.Migration

  def up do
    drop table("all_locales")

    alter table(:locales) do
      add :is_enabled, :boolean, default: false
      add :name, :string
      add :local_name, :string
    end

    create unique_index("locales", [:lang])

    execute "UPDATE locales SET is_enabled= true, name = 'English', local_name = 'English' WHERE lang = 'en'"

    execute "UPDATE locales SET is_enabled= true, name = 'Spanish', local_name = 'Español' WHERE lang = 'es'"
  end

  def down do
    drop_if_exists(index("locales", ["lang"]))

    alter table(:locales) do
      remove :is_enabled
      remove :name
      remove :local_name
    end

    create table(:all_locales) do
      add :name, :string
      add :local, :string
      add :code, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index("all_locales", [:code])
  end
end
