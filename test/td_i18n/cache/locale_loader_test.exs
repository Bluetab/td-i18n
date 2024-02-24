defmodule TdI18n.Cache.LocaleLoaderTest do
  use TdI18n.DataCase

  alias TdI18n.Cache.LocaleLoader

  setup do
    on_exit(fn -> TdCache.Redix.del!("i18n:locales:*") end)
  end

  describe "reload/0" do
    test "returns lang 'en' and 0 when does not have any default lang " do
      assert {:ok, {"en", 0}} = LocaleLoader.reload()
    end

    test "returns {default_locale, count required locales}" do
      %{lang: lang} = insert(:locale, is_required: true, is_default: true)
      insert(:locale, is_required: true)
      insert(:locale, is_required: true)
      assert {:ok, {^lang, 2}} = LocaleLoader.reload()
    end
  end
end
