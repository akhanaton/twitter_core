alias Twitter.Core.{
  Account,
  AccountsSupervisor,
  Comment,
  User,
  Timeline,
  Tweet,
  TweetLog,
  TweetServer,
  TweetLogSupervisor
}

{:ok, user1} = User.new("alice@fakemail.fake", "Alice Bryan", "alice")
{:ok, user2} = User.new("bob@fakemail.fake", "Bob Cummins", "bob")
{:ok, user3} = User.new("freddy@fakemail.fake", "Fred Grange", "freddy")
account_pid1 = AccountsSupervisor.account_process(user1)
account_pid2 = AccountsSupervisor.account_process(user2)
account_pid3 = AccountsSupervisor.account_process(user3)
via_account1 = Account.via_tuple("alice")
via_account2 = Account.via_tuple("bob")
via_account3 = Account.via_tuple("freddy")
via_log1 = Twitter.Core.TweetServer.via_tuple("alice")
via_log2 = Twitter.Core.TweetServer.via_tuple("bob")
via_log3 = Twitter.Core.TweetServer.via_tuple("freddy")
%{timeline: timeline1, user: user1} = :sys.get_state(account_pid1)
%{timeline: timeline2, user: user2} = :sys.get_state(account_pid2)
%{timeline: timeline3, user: user3} = :sys.get_state(account_pid3)
Account.toggle_follower(user1, user2)
Account.toggle_follower(user1, user3)
Account.toggle_follower(user2, user1)
Account.toggle_follower(user2, user3)
tweet1 = Tweet.new("Hello world!")
tweet2 = Tweet.new("My name is alice")
tweet3 = Tweet.new("My name is bob")
tweet4 = Tweet.new("This is freddy")
tweet5 = Tweet.new("Someone follow me please.")
TweetServer.tweet(user1, tweet1)
tweet1 = TweetServer.get_last_tweet(user1)
TweetServer.tweet(user1, tweet2)
tweet2 = TweetServer.get_last_tweet(user1)
TweetServer.tweet(user2, tweet3)
tweet3 = TweetServer.get_last_tweet(user2)
TweetServer.tweet(user3, tweet4)
tweet4 = TweetServer.get_last_tweet(user3)
TweetServer.tweet(user3, tweet5)
tweet5 = TweetServer.get_last_tweet(user3)
%{timeline: timeline1, user: user1} = :sys.get_state(account_pid1)
%{timeline: timeline2, user: user2} = :sys.get_state(account_pid2)
%{timeline: timeline3, user: user3} = :sys.get_state(account_pid3)
TweetServer.add_comment(user3, tweet1, "Hi alice its freddy, will you follow me?")
tweet1 = TweetServer.get_tweet(user1, tweet1.id)
TweetServer.add_comment(user2, tweet1, "Hi alice its bob, thanks for the follow.")
TweetServer.add_comment(user1, tweet5, "Sorry freddy, you are not worth a follow.")
tweet1 = TweetServer.get_tweet(user1, tweet1.id)
tweet5 = TweetServer.get_tweet(user3, tweet5)
