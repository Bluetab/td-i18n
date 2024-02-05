defmodule TdI18n.Locales.LocaleTest do
  use TdI18n.DataCase

  alias TdI18n.Locales.Locale

  describe "changeset/2" do
    test "validates fields valid values" do
      assert %{errors: []} =
               Locale.changeset(%Locale{}, %{lang: "td", name: "Truedat", local_name: "Truedis"})
    end

    test "validates required fields" do
      assert %{errors: errors} = Locale.changeset(%Locale{}, %{})

      assert {_, [validation: :required]} = errors[:lang]
      assert {_, [validation: :required]} = errors[:name]
      assert {_, [validation: :required]} = errors[:local_name]
    end

    test "validates field types" do
      assert %{errors: errors} =
               Locale.changeset(
                 %Locale{},
                 %{
                   lang: 1,
                   is_required: "lorem",
                   is_default: "ipsum",
                   is_enabled: "dolor",
                   name: 1,
                   local_name: 1
                 }
               )

      assert {_, [{:type, :string}, {:validation, :cast}]} = errors[:lang]
      assert {_, [{:type, :string}, {:validation, :cast}]} = errors[:name]
      assert {_, [{:type, :string}, {:validation, :cast}]} = errors[:local_name]
      assert {_, [{:type, :boolean}, {:validation, :cast}]} = errors[:is_required]
      assert {_, [{:type, :boolean}, {:validation, :cast}]} = errors[:is_default]
      assert {_, [{:type, :boolean}, {:validation, :cast}]} = errors[:is_enabled]
    end
  end
end
