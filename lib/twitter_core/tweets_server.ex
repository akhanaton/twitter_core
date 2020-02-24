defmodule Twitter.Core.TweetServer do
  use GenServer, restart: :permanent

  alias Twitter.Core.{ProcessRegistry, Tweet, TweetLog, User}

  # Interface functions

  def start_link(%User{username: username} = user) do
    IO.puts("starting tweet log server for #{username}")
    GenServer.start_link(__MODULE__, user, name: via_tuple(username))
  end

  def all_tweets(%User{username: username}) do
    GenServer.call(via_tuple(username), :all_tweets)
  end

  def get_last_tweet(%User{username: username}) do
    GenServer.call(via_tuple(username), :get_last)
  end

  def tweet(%Tweet{} = tweet, %User{username: username}) do
    GenServer.call(via_tuple(username), {:tweet, tweet})
  end

  def init(user) do
    send(self(), {:set_state, user})
    {:ok, %{}}
  end

  def handle_call(:all_tweets, _caller, state) do
    all_tweets = TweetLog.all_tweets(state)
    reply_success(state, all_tweets)
  end

  def handle_call(:get_last_tweet, _caller, state) do
    last = TweetLog.get_last(state)
    reply_success(state, last)
  end

  def handle_call({:tweet, tweet}, _caller, state) do
    with {:ok, new_state} <- TweetLog.add_tweet(state, tweet) do
      update_timelines(new_state)
      reply_success(new_state, new_state)
    else
      :error ->
        reply_success(state, state)
    end
  end

  def handle_info({:set_state, user}, _state) do
    state = TweetLog.new(user)
    {:noreply, state}
  end

  def via_tuple(username) do
    ProcessRegistry.via_tuple({__MODULE__, username})
  end

  defp reply_success(%{} = state, reply) do
    {:reply, reply, state}
  end

  defp update_timelines(%{tweets: _tweets, user_id: user_id}) do
    [{_user_id, log_owner}] = :ets.lookup(:user_state, user_id)

    [{my_pid, _}] =
      Registry.lookup(
        ProcessRegistry,
        {Twitter.Core.Account, log_owner}
      )

    send(my_pid, :update_timeline)
  end
end
