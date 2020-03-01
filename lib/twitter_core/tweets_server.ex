defmodule Twitter.Core.TweetServer do
  use GenServer, restart: :permanent

  alias Twitter.Core.{Comment, ProcessRegistry, Tweet, TweetLog, User}

  # Interface functions

  def start_link(%User{username: username} = user) do
    IO.puts("starting tweet log server for #{username}")
    GenServer.start_link(__MODULE__, user, name: via_tuple(username))
  end

  def add_comment(%User{username: username}, %Tweet{} = tweet, comment) do
    GenServer.call(via_tuple(username), {:add_comment, {tweet, comment}})
  end

  def all_tweets(%User{username: username}) do
    GenServer.call(via_tuple(username), :all_tweets)
  end

  def delete_comment(
        %User{username: username} = _tweet_log_owner,
        %User{id: deleter_id} = _comment_deleter,
        %Tweet{} = tweet,
        %Comment{user_id: commenter_id} = comment
      ) do
    case commenter_id == deleter_id do
      true ->
        GenServer.call(via_tuple(username), {:delete_comment, tweet, comment})

      false ->
        {:error, :not_your_comment}
    end
  end

  def delete_tweet(%User{username: username}, %Tweet{} = tweet) do
    GenServer.call(via_tuple(username), {:delete_tweet, tweet})
  end

  def get_last_tweet(%User{username: username}) do
    GenServer.call(via_tuple(username), :get_last_tweet)
  end

  def get_tweet(%User{username: username}, tweet_id) do
    GenServer.call(via_tuple(username), {:get_tweet, tweet_id})
  end

  def toggle_like_comment(
        %Tweet{} = tweet,
        comment_id,
        %User{username: username}
      ) do
    GenServer.cast(
      via_tuple(username),
      {:toggle_like_comment, tweet, comment_id}
    )
  end

  def toggle_like_tweet(%Tweet{} = tweet, %User{username: username}) do
    GenServer.cast(via_tuple(username), {:toggle_like_tweet, tweet})
  end

  def tweet(%User{username: username}, %Tweet{} = tweet) do
    GenServer.call(via_tuple(username), {:tweet, tweet})
  end

  def init(user) do
    send(self(), {:set_state, user})
    {:ok, %{}}
  end

  def handle_call(
        {:add_comment, {tweet, comment}},
        _caller,
        %{tweets: _tweets, user_id: user_id} = state
      ) do
    tweet_user_details = user_details(tweet.user_id)
    my_details = user_details(user_id)

    with {:ok, tweet} <-
           Tweet.add_comment(
             tweet,
             my_details,
             comment
           ) do
      GenServer.cast(
        via_tuple(tweet_user_details.username),
        {:update_tweet, tweet}
      )

      reply_success(state, :ok)
    else
      error_message = {:error, _message} ->
        reply_success(state, error_message)
    end
  end

  def handle_call(:all_tweets, _caller, state) do
    all_tweets = TweetLog.all_tweets(state)
    reply_success(state, all_tweets)
  end

  def handle_call({:delete_tweet, tweet}, _caller, state) do
    case TweetLog.delete_tweet(state, tweet) do
      {:ok, new_state} -> reply_success(new_state, :ok)
      {:error, message} -> reply_success(state, message)
    end
  end

  def handle_call(
        {:delete_comment, tweet, comment},
        _caller,
        state
      ) do
    with {:ok, %Tweet{} = deleted_tweet} <- Tweet.delete_comment(tweet, comment),
         {:ok, %TweetLog{} = new_state} <-
           TweetLog.update_tweet(state, deleted_tweet) do
      reply_success(new_state, :ok)
    else
      {:error, message} -> reply_success(state, {:error, message})
    end
  end

  def handle_call(:get_last_tweet, _caller, state) do
    last = TweetLog.get_last(state)
    reply_success(state, last)
  end

  def handle_call({:get_tweet, tweet_id}, _caller, state) do
    case TweetLog.get_tweet(state, tweet_id) do
      {:ok, tweet} -> reply_success(state, tweet)
      {:error, error_message} -> reply_success(state, {:error, error_message})
    end
  end

  def handle_call({:tweet, tweet}, _caller, state) do
    with {:ok, new_state} <- TweetLog.add_tweet(state, tweet) do
      update_my_timeline(new_state)
      reply_success(new_state, new_state)
    else
      :error ->
        reply_success(state, state)
    end
  end

  def handle_cast({:toggle_like_comment, tweet, comment_id}, state) do
    my_details = user_details(state.user_id)

    case tweet.user_id == state.user_id do
      true ->
        with {:ok, tweet} <- Map.fetch(state.tweets, tweet.id),
             {:ok, comment} <- Map.fetch(tweet.comments, comment_id),
             {:ok, new_comment} <- Comment.toggle_like(comment, my_details),
             {:ok, new_tweet} <- Tweet.update_comment(tweet, new_comment),
             {:ok, new_state} <- TweetLog.update_tweet(state, new_tweet) do
          {:noreply, new_state}
        end

      false ->
        tweet_owner = user_details(tweet.user_id)

        with %{tweets: tweets, user_id: _user_id} <-
               GenServer.call(via_tuple(tweet_owner.username), :all_tweets),
             {:ok, tweet} <- Map.fetch(tweets, tweet.id),
             {:ok, comment} <- Map.fetch(tweet.comments, comment_id),
             {:ok, new_comment} <- Comment.toggle_like(comment, my_details),
             {:ok, new_tweet} <- Tweet.update_comment(tweet, new_comment) do
          GenServer.cast(via_tuple(tweet_owner.username), {:update_tweet, new_tweet})
          {:noreply, state}
        end
    end
  end

  def handle_cast({:toggle_like_tweet, tweet}, state) do
    my_details = user_details(state.user_id)
    %User{username: owner_name} = user_details(tweet.user_id)
    toggled_tweet = Tweet.toggle_like(tweet, my_details)
    GenServer.cast(via_tuple(owner_name), {:update_tweet, toggled_tweet})
    {:noreply, state}
  end

  def handle_cast({:update_tweet, %Tweet{} = tweet}, state) do
    case TweetLog.update_tweet(state, tweet) do
      {:ok, new_state} -> {:noreply, new_state}
      _ -> {:noreply, state}
    end
  end

  def handle_info({:set_state, user}, _state) do
    state = TweetLog.new(user)
    {:noreply, state}
  end

  def via_tuple(username) do
    ProcessRegistry.via_tuple({__MODULE__, username})
  end

  defp log_owner(user_id) do
    [{_user_id, log_owner}] = :ets.lookup(:user_state, user_id)
    log_owner
  end

  defp user_details(user_id) do
    log_owner = log_owner(user_id)
    [{_key, user_details}] = :ets.lookup(:user_state, log_owner)
    user_details
  end

  defp reply_success(%{} = state, reply) do
    {:reply, reply, state}
  end

  defp update_my_timeline(%{tweets: _tweets, user_id: user_id}) do
    log_owner = log_owner(user_id)

    [{my_pid, _}] =
      Registry.lookup(
        ProcessRegistry,
        {Twitter.Core.Account, log_owner}
      )

    send(my_pid, :update_timeline)
  end
end
