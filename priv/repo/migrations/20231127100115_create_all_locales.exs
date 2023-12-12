defmodule TdI18n.Repo.Migrations.CreateAllLocales do
  use Ecto.Migration

  def change do
    create table(:all_locales) do
      add :name, :string
      add :local, :string
      add :code, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index("all_locales", [:code])
  end
end
