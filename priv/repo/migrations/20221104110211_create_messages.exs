defmodule TdI18n.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table("messages") do
      add :message_id, :string, null: false
      add :definition, :string, null: false
      add :description, :string
      add :locale_id, references("locales", on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index("messages", [:locale_id, :message_id])
  end
end
