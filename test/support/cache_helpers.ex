defmodule CacheHelpers do
  @moduledoc """
  Helper functions for loading and cleaning test fixtures in cache
  """

  import ExUnit.Callbacks, only: [on_exit: 1]
  import TdI18n.Factory

  alias TdCache.Permissions
  alias TdCache.Redix
  alias TdCache.TaxonomyCache
  alias TdCache.UserCache

  def put_user(params \\ %{}) do
    %{id: id} = user = build(:user, params)
    on_exit(fn -> UserCache.delete(id) end)
    {:ok, _} = UserCache.put(user)
    user
  end

  def put_domain(params \\ %{}) do
    %{id: id} = domain = build(:domain, params)
    on_exit(fn -> TaxonomyCache.delete_domain(id, clean: true) end)
    {:ok, _} = TaxonomyCache.put_domain(domain)
    domain
  end

  def put_session_permissions(%{} = claims, domain_id, permissions) do
    domain_ids_by_permission = Map.new(permissions, &{to_string(&1), [domain_id]})
    put_session_permissions(claims, domain_ids_by_permission)
  end

  def put_session_permissions(%{jti: session_id, exp: exp}, %{} = domain_ids_by_permission) do
    put_sessions_permissions(session_id, exp, domain_ids_by_permission)
  end

  def put_sessions_permissions(session_id, exp, domain_ids_by_permission) do
    on_exit(fn -> Redix.del!("session:#{session_id}:permissions") end)
    Permissions.cache_session_permissions!(session_id, exp, domain_ids_by_permission)
  end
end
