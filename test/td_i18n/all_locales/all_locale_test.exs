defmodule TdI18n.AllLocales.AllLocaleTest do
  use TdI18n.DataCase

  alias TdI18n.AllLocales.AllLocale

  describe "changeset/2" do
    test "validates fields valid values" do
      assert %{errors: []} =
               AllLocale.changeset(%AllLocale{}, %{code: "td", name: "Truedat", local: "Trudish"})
    end

    test "validates required fields" do
      assert %{errors: errors} = AllLocale.changeset(%AllLocale{}, %{})

      assert {_, [validation: :required]} = errors[:code]
      assert {_, [validation: :required]} = errors[:name]
      assert {_, [validation: :required]} = errors[:local]
    end

    test "validates field types" do
      assert %{errors: errors} =
               AllLocale.changeset(
                 %AllLocale{},
                 %{code: 1, name: 1, local: 1}
               )

      assert {_, [{:type, :string}, {:validation, :cast}]} = errors[:code]
      assert {_, [{:type, :string}, {:validation, :cast}]} = errors[:name]
      assert {_, [{:type, :string}, {:validation, :cast}]} = errors[:local]
    end
  end
end
