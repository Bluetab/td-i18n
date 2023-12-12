defmodule TdI18n.AllLocalesTest do
  use TdI18n.DataCase

  alias TdI18n.AllLocales

  describe "list_all_locales/0" do
    test "list_all_locales/0 returns all locales" do
      all_locale = insert(:all_locale)

      AllLocales.list_all_locale()
      |> assert_lists_equal(
        [all_locale],
        &assert_structs_equal(&1, &2, [:code, :name, :local])
      )
    end
  end

  describe "load_from_file!/1" do
    test "load all_locates without duplicating" do
      insert(:all_locale)
      assert {:ok, {2, _}} = AllLocales.load_from_file!("test/fixtures/all_locales_test.json")
    end
  end
end
