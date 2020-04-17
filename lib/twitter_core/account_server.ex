defmodule Twitter.Core.AccountServer do
  alias Twitter.Core.{
    LiveUpdates,
    ProcessRegistry,
    Timeline,
    Tweet,
    TweetLogSupervisor,
    TweetServer,
    User
  }

  use GenServer, restart: :transient

  @timeout 60 * 60 * 1000

  # Interface functions

  def start_link(%User{username: username} = user) when is_binary(username) do
    GenServer.start_link(__MODULE__, user, name: via_tuple(username))
  end

  def tweets(%User{username: username}) do
    GenServer.call(via_tuple(username), :show_tweets)
  end

  def toggle_follower(%User{username: username}, %User{} = follower) do
    GenServer.call(via_tuple(username), {:toggle_follower, follower})
  end

  # Server functions

  def init(user) do
    send(self(), {:set_state, user})
    {:ok, %{}, @timeout}
  end

  def handle_call(:user, _caller, %{user: user_details, timeline: _timeline} = state) do
    reply_success(state, user_details)
  end

  def handle_call(:show_tweets, _caller, %{user: user_details, timeline: timeline} = state) do
    result =
      Stream.map(timeline.tweets, fn {tweet_id, tweet} ->
        user =
          case tweet.user_id == user_details.id do
            true ->
              user_details

            false ->
              [{_user_id, username}] = :ets.lookup(:user_state, tweet.user_id)
              [{_username, user_details}] = :ets.lookup(:user_state, username)
              user_details
          end

        GenServer.call(TweetServer.via_tuple(user.username), {:get_tweet, tweet_id})
      end)
      |> Enum.sort_by(& &1.created, &Timex.after?/2)

    reply_success(state, result)
  end

  def handle_call(
        {:toggle_follower, follower},
        _caller,
        %{timeline: _timeline, user: user_details} = state
      ) do
    with new_user = %User{} <- User.toggle_follower(user_details, follower),
         %User{} <-
           GenServer.call(
             via_tuple(follower.username),
             {:toggle_following, user_details}
           ) do
      new_state = %{state | user: new_user}
      reply_success(new_state, new_user)
    else
      _ -> reply_success(state, user_details)
    end
  end

  def handle_call(
        {:toggle_following, %User{} = followed_user},
        _caller,
        %{timeline: _timeline, user: user_details} = state
      ) do
    with new_user = %User{} <- User.toggle_following(user_details, followed_user) do
      %{state | user: new_user}
      |> reply_success(new_user)
    else
      _ -> reply_success(state, state)
    end
  end

  def handle_cast(
        {:add_to_timeline, tweet},
        %{user: user, timeline: timeline}
      ) do
    new_timeline = Timeline.add(timeline, tweet)
    state = %{user: user, timeline: new_timeline}
    {:noreply, state}
  end

  def handle_cast(
        {:followed_tweets_to_timeline, %Tweet{} = tweet, %User{}},
        %{
          user: user,
          timeline: timeline
        } = state
      ) do
    new_timeline = Timeline.add(timeline, tweet)
    new_state = %{state | timeline: new_timeline}
    LiveUpdates.notify_live_view(user.username, {__MODULE__, [:timeline_updated], []})

    {:noreply, new_state}
  end

  def handle_info({:set_state, %User{username: username} = user}, _state) do
    user_details =
      case :ets.lookup(:user_state, username) do
        [] -> create_user(user)
        [{_key, state}] -> state
      end

    tweets = my_tweets(username) ++ following_tweets(user_details)

    timeline = Timeline.new()

    Enum.each(tweets, fn tweet ->
      GenServer.cast(via_tuple(username), {:add_to_timeline, tweet})
    end)

    state = %{user: user_details, timeline: timeline}
    :ets.insert(:user_state, {user_details.username, user_details})
    :ets.insert(:user_state, {user_details.id, user_details.username})
    IO.puts("started account server for #{user_details.username}")
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state),
    do: {:stop, {:shutdown, :timeout}, state}

  def handle_info(
        :update_timeline,
        %{
          user: %User{username: username} = user,
          timeline: timeline
        } = state
      ) do
    new_tweet = GenServer.call(TweetServer.via_tuple(username), :get_last_tweet)
    new_timeline = Timeline.add(timeline, new_tweet)
    new_state = %{state | timeline: new_timeline}
    LiveUpdates.notify_live_view(username, {__MODULE__, [:timeline_updated], []})
    update_followers_timelines(user, new_tweet)
    {:noreply, new_state}
  end

  def terminate({:shutdown, :timeout}, _state) do
    :ok
  end

  def terminate(_reason, _state), do: :ok

  def via_tuple(username) do
    ProcessRegistry.via_tuple({__MODULE__, username})
  end

  # Private functions
  defp create_user(%User{
         email: email,
         name: name,
         username: username
       }) do
    with user <- User.new(email, name, username) do
      IO.puts("User created.")

      user = %{user | id: UUID.uuid1()}
      TweetLogSupervisor.log_process(user)

      user
    end
  end

  defp following_tweets(%User{following: following}) do
    Enum.reduce(following, [], fn followed_user, acc ->
      [{_user_id, followed_username}] = :ets.lookup(:user_state, followed_user)

      GenServer.call(TweetServer.via_tuple(followed_username), :all_tweets) ++ acc
    end)
  end

  defp my_tweets(username) do
    GenServer.call(TweetServer.via_tuple(username), :all_tweets)
  end

  defp reply_success(%{user: user_details, timeline: _timeline} = state, reply) do
    :ets.insert(:user_state, {user_details.username, user_details})
    :ets.insert(:user_state, {user_details.id, user_details.username})
    {:reply, reply, state, @timeout}
  end

  defp update_followers_timelines(user, tweet) do
    Enum.each(user.followers, fn follower ->
      [{_user_id, follower_username}] = :ets.lookup(:user_state, follower)
      GenServer.cast(via_tuple(follower_username), {:followed_tweets_to_timeline, tweet, user})
    end)
  end
end
