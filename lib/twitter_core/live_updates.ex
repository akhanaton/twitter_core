defmodule Twitter.Core.LiveUpdates do
  @pubsub_name :twitter

  def subscribe_live_view(user) do
    IO.puts("subscribed.")
    Phoenix.PubSub.subscribe(@pubsub_name, user)
  end

  def notify_live_view(user, message) do
    IO.puts("notifying #{user}")
    Phoenix.PubSub.broadcast(@pubsub_name, user, message)
  end
end
