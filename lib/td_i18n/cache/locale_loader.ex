defmodule TdI18n.Cache.LocaleLoader do
  @moduledoc """
  Provides functionality to load locales into distributed cache
  """

  alias TdCache.I18nCache
  alias TdI18n.Locales

  require Logger

  @default_lang "en"

  def reload do
    Logger.info("Reloading default and required locales")

    # Clean all existing cache data for all locales
    Enum.each(I18nCache.get_active_locales!(), &I18nCache.delete/1)

    {default_locale, count} = put_default_and_required_locales()

    load_enabled_messages()

    Logger.info("Set default lang '#{default_locale}' and #{count} required locales")
    {:ok, {default_locale, count}}
  end

  def put_default_and_required_locales do
    # Get and set default locale
    default_locale = get_default_locale()
    {:ok, _} = I18nCache.put_default_locale(default_locale)

    # Get and set required locales
    required_locales = get_required_locales()
    {:ok, [_, count]} = I18nCache.put_required_locales(required_locales)
    {default_locale, count}
  end

  defp get_default_locale do
    case Locales.get_default_locale() do
      nil -> @default_lang
      %{lang: lang} -> lang
    end
  end

  defp get_required_locales do
    Locales.get_required_locales()
    |> Enum.map(& &1.lang)
  end

  defp load_enabled_messages do
    # Query only enabled locales with their messages
    Locales.list_locales(
      preload: :messages,
      filters: [is_enabled: true]
    )
    |> Enum.each(fn locale ->
      # Clean existing messages for this locale
      I18nCache.delete(locale.lang)
      # Load all messages
      Enum.each(locale.messages, fn message ->
        I18nCache.put(locale.lang, %{
          message_id: message.message_id,
          definition: message.definition
        })
      end)
    end)
  end
end
