defmodule TdI18n.Locales.LocaleTest do
  use TdI18n.DataCase

  alias TdI18n.Locales.Locale

  describe "changeset/2" do
    test "validates fields valid values" do
      assert %{errors: []} = Locale.changeset(%Locale{}, %{lang: "td"})
    end

    test "validates required fields" do
      assert %{errors: errors} = Locale.changeset(%Locale{}, %{})

      assert {_, [validation: :required]} = errors[:lang]
    end

    test "validates field types" do
      assert %{errors: errors} =
               Locale.changeset(
                 %Locale{},
                 %{lang: 1, is_required: "lorem", is_default: "ipsum"}
               )

      assert {_, [{:type, :string}, {:validation, :cast}]} = errors[:lang]
      assert {_, [{:type, :boolean}, {:validation, :cast}]} = errors[:is_required]
      assert {_, [{:type, :boolean}, {:validation, :cast}]} = errors[:is_default]
    end
  end
end
