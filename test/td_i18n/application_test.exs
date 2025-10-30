defmodule TdI18n.ApplicationTest do
  use ExUnit.Case

  alias TdI18n.Application

  describe "config_change/3" do
    test "returns :ok" do
      assert :ok == Application.config_change([some: :config], [], [])
    end

    test "handles changed configuration" do
      changed = [some: :value, another: :config]
      removed = [:old_key]

      assert :ok == Application.config_change(changed, [], removed)
    end

    test "handles empty changes" do
      assert :ok == Application.config_change([], [], [])
    end
  end
end
