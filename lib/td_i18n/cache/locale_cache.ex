defmodule TdI18n.Cache.LocaleCache do
  @moduledoc """
  Cache for locales and messages.
  """

  use GenServer
  require Logger

  alias TdI18n.Locales
  alias TdI18n.Repo
  alias TdI18nWeb.LocaleView

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Client API

  def get_locales do
    GenServer.call(__MODULE__, :get_locales)
  end

  def get_stats do
    GenServer.call(__MODULE__, :get_stats)
  end

  def refresh do
    GenServer.cast(__MODULE__, :refresh)
  end

  # Server callbacks

  @impl true
  def init(_) do
    {:ok, %{json: nil, refresh_count: 0, refresh_timer: nil, refresh_waiters: []}}
  end

  @impl true
  def handle_call(:get_locales, from, %{refresh_timer: nil, json: nil} = state) do
    send(self(), :do_refresh)

    {:noreply,
     %{state | refresh_timer: :pending, refresh_waiters: [from | state.refresh_waiters]}}
  end

  def handle_call(:get_locales, from, %{refresh_timer: timer} = state) when not is_nil(timer) do
    {:noreply, %{state | refresh_waiters: [from | state.refresh_waiters]}}
  end

  def handle_call(:get_locales, _from, state) do
    {:reply, state.json, state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = Map.take(state, [:refresh_count])
    {:reply, stats, state}
  end

  @impl true
  def handle_cast(:refresh, %{refresh_timer: nil} = state) do
    send(self(), :do_refresh)
    {:noreply, %{state | refresh_timer: :pending}}
  end

  def handle_cast(:refresh, state), do: {:noreply, state}

  @impl true
  def handle_info(:do_refresh, state) do
    new_json =
      Repo.checkout(fn ->
        fetch_and_encode_locales()
      end)

    Enum.each(state.refresh_waiters, &GenServer.reply(&1, new_json))

    new_state = %{
      state
      | json: new_json,
        refresh_count: state.refresh_count + 1,
        refresh_timer: nil,
        refresh_waiters: []
    }

    {:noreply, new_state}
  end

  # Private functions

  defp fetch_and_encode_locales do
    locales = Locales.list_locales(preload: :messages, filters: [is_enabled: true])

    Logger.info("Refreshing cache with #{length(locales)} locales.")

    LocaleView
    |> Phoenix.View.render("index.json", %{locales: locales})
    |> Jason.encode!()
  end
end
