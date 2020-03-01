defmodule TimelineTest do
  use ExUnit.Case

  alias Twitter.Core.{Timeline, Tweet, User}

  setup do
    timeline = Timeline.new()
    {:ok, user} = User.new("alice@gmail.com", "Alice B.", "alice")
    user = %{user | id: UUID.uuid1()}
    tweet = Tweet.new("Hello world!")
    tweet = %{tweet | id: UUID.uuid1(), user_id: user.id}

    [timeline: timeline, user: user, tweet: tweet]
  end

  test "add a tweet to the timeline", state do
    timeline = state[:timeline]
    user = state[:user]
    tweet = state[:tweet]

    timeline = Timeline.add(timeline, tweet)

    assert Enum.count(timeline.tweets) == 1
    tweet_meta = Map.fetch!(timeline.tweets, tweet.id)
    assert tweet_meta.user_id == user.id
    assert tweet.id == tweet_meta.tweet_id
  end

  test "delete tweet from timeline", state do
    timeline = state[:timeline]
    user = state[:user]
    tweet = state[:tweet]

    timeline = Timeline.add(timeline, tweet)

    {:ok, second_user} = User.new("alice@gmail.com", "Alice B.", "alice")
    second_user = %{user | id: UUID.uuid1()}

    second_tweet = Tweet.new("My second tweet")
    second_tweet = %{second_tweet | id: UUID.uuid1(), user_id: second_user.id}

    timeline = Timeline.add(timeline, second_tweet)

    assert Enum.count(timeline.tweets) == 2

    {:ok, timeline} = Timeline.delete(timeline, tweet)

    assert assert Enum.count(timeline.tweets) == 1

    tweet_meta = Map.fetch!(timeline.tweets, second_tweet.id)
    assert second_user.id == tweet_meta.user_id
    assert tweet_meta.tweet_id == second_tweet.id
  end
end
