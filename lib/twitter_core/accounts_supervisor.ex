defmodule Twitter.Core.AccountsSupervisor do
  alias Twitter.Core.{AccountServer, User}

  def start_link do
    IO.puts("starting accounts supervisor...")

    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  def account_process(%User{} = user) do
    case start_child(user) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp start_child(user) do
    DynamicSupervisor.start_child(__MODULE__, {AccountServer, user})
  end
end
