defmodule AccountTest do
  use ExUnit.Case

  @subject Twitter.Core.Account

  alias Twitter.Core.{ProcessRegistry, Tweet, TweetServer, User}

  setup do
    {:ok, user1} = User.new("alice@fakemail.fake", "Alice Bryan", "alice")

    # account_pid1 = AccountsSupervisor.account_process(user1)
    {:ok, account_pid1} = start_supervised({Twitter.Core.Account, user1})

    :timer.sleep(200)

    via_log1 = Twitter.Core.TweetServer.via_tuple("alice")
    tweet1 = Tweet.new("Hello world!")
    TweetServer.tweet(user1, tweet1)
    :timer.sleep(200)
    %{timeline: timeline1, user: user1} = :sys.get_state(account_pid1)

    on_exit(fn ->
      GenServer.stop(via_log1, :normal)
    end)

    [
      account_pid: account_pid1,
      timeline: timeline1,
      tweet: tweet1,
      user: user1
    ]
  end

  describe "tweets/2" do
    # @tag :pending
    test "retrieve tweets from users tweetlog", state do
      tweet = state[:tweet]
      user = state[:user]

      [actual] = @subject.tweets(user)

      assert %{content: tweet.content} == %{content: actual.content}
    end

    # @tag :pending
    test "tweets are sorted from newest to oldest", state do
      user = state[:user]

      tweet2 = Tweet.new("Second tweet")
      TweetServer.tweet(user, tweet2)

      [actual | _rest] = @subject.tweets(user)

      assert %{content: tweet2.content} == %{content: actual.content}
    end
  end

  # @tag :pending
  describe "toggle_follower/2" do
    test "followed user should be in my following", state do
      user = state[:user]
      :timer.sleep(100)
      {:ok, user2} = User.new("bob@fakemail.fake", "Bob C.", "bob")
      {:ok, account_pid2} = @subject.start_link(user2)
      :timer.sleep(100)
      via_log = Twitter.Core.TweetServer.via_tuple("bob")
      %{timeline: timeline, user: user2} = :sys.get_state(account_pid2)

      actual = @subject.toggle_follower(user, user2)

      assert user2.id in actual.followers

      GenServer.stop(account_pid2, :normal)
      GenServer.stop(via_log, :normal)
    end
  end
end
