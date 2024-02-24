defmodule TdI18n.Cache.LocaleLoader do
  @moduledoc """
  Provides functionality to load locales into distributed cache
  """

  alias TdCache.I18nCache
  alias TdI18n.Locales

  require Logger

  @default_lang "en"

  def reload do
    Logger.info("Reloading defautl and required locales")

    default_locale = get_default_locale()
    required_locales = get_required_locales()

    {:ok, _} = I18nCache.put_default_locale(default_locale)
    {:ok, [_, count]} = I18nCache.put_required_locales(required_locales)
    Logger.info("set default lang '#{default_locale}' and set #{count} requireds")
    {:ok, {default_locale, count}}
  end

  def get_default_locale do
    case Locales.get_default_locale() do
      nil -> @default_lang
      %{lang: lang} -> lang
    end
  end

  def get_required_locales do
    locales = Locales.get_required_locales()

    Enum.reduce(locales, [], fn %{lang: lang}, acc ->
      [lang | acc]
    end)
  end
end
