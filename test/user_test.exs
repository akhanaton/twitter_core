defmodule UserTest do
  use ExUnit.Case
  alias Twitter.Core.User

  setup do
    {:ok, user} =
      User.new(
        "jane@gmail.com",
        "Jane Jacobs",
        "jane"
      )

    user = %{user | id: UUID.uuid1()}
    [user: user]
  end

  test "creates a new user", user do
    setup_user = user[:user]
    assert setup_user.name =~ "Jane Jacobs"
    assert setup_user.email =~ "jane@gmail.com"
    assert setup_user.username =~ "jane"
  end

  test "add/remove user from followers", user do
    setup_user = user[:user]

    # create a user to follow setup_user
    {:ok, follower} = User.new("jdoe@gmail.com", "John Doe", "jdog")
    follower = %{follower | id: UUID.uuid1()}

    # user `follower` follows `setup_user`
    setup_user = %User{} = User.toggle_follower(setup_user, follower)
    assert MapSet.member?(setup_user.followers, follower.id) == true
    assert follower.id in setup_user.followers

    # user `follower` unfollows  `setup_user`
    setup_user = %User{} = User.toggle_follower(setup_user, follower)
    assert MapSet.member?(setup_user.followers, follower.id) == false
  end

  test "add/remove user from following", user do
    setup_user = user[:user]

    # create a user for setup_user to follow
    {:ok, followed} = User.new("jdoe@gmail.com", "John Doe", "jdog")
    followed = %{followed | id: UUID.uuid1()}

    # user `follow` follows `setup_user`
    setup_user = %User{} = User.toggle_following(setup_user, followed)
    assert MapSet.member?(setup_user.following, followed.id) == true
    assert followed.id in setup_user.following

    # user `follow` unfollows  `setup_user`
    setup_user = %User{} = User.toggle_following(setup_user, followed)
    assert MapSet.member?(setup_user.followers, followed.id) == false
  end
end
