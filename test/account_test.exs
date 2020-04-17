defmodule AccountTest do
  use ExUnit.Case

  @subject Twitter.Core.AccountServer

  alias Twitter.Core.{Timeline, Tweet, User}

  setup do
    user = User.new("alice@fakemail.fake", "Alice Bryan", "alice")
    user = %{user | id: UUID.uuid1()}
    tweet1 = Tweet.new("First tweet")
    tweet2 = Tweet.new("Second tweet")
    tweet1 = %{tweet1 | id: UUID.uuid1(), user_id: user.id}
    tweet2 = %{tweet2 | id: UUID.uuid1(), user_id: user.id}
    timeline = Timeline.new()
    timeline = Timeline.add(timeline, tweet1)
    timeline = Timeline.add(timeline, tweet2)
    account = %{user: user, timeline: timeline}

    %{account: account}
  end

  test "get user details", %{account: account} do
    expected = account.user
    assert {:reply, actual, _, _} = @subject.handle_call(:user, "caller", account)
    assert ^expected = actual
  end

  test "add user id to following", %{account: account} do
    user = User.new("bob@fakemail.fake", "Bob C.", "bob")
    user = %{user | id: UUID.uuid1()}

    assert {:reply, actual, _, _} =
             @subject.handle_call({:toggle_following, user}, "caller", account)

    assert user.id in actual.following
  end
end
