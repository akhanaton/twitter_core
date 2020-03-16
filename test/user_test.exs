defmodule UserTest do
  use ExUnit.Case, async: true

  @subject Twitter.Core.User

  # doctest @subject

  setup do
    {:ok, user} =
      @subject.new(
        "jane@gmail.com",
        "Jane Jacobs",
        "jane"
      )

    user = %{user | id: UUID.uuid1()}
    [user: user]
  end

  describe "new/3" do
    test "returns {:ok, user}" do
      expected_name = "Jane Jacobs"
      expected_email = "jane@gmail.com"
      expected_username = "jane"

      {:ok, actual_user} =
        @subject.new(
          "jane@gmail.com",
          "Jane Jacobs",
          "jane"
        )

      %{name: name, email: email, username: username} = actual_user

      assert ^name = expected_name
      assert ^email = expected_email
      assert ^username = expected_username
    end
  end

  describe "toggle_follower/2" do
    test "will toggle user id of passed in follower", user do
      setup_user = user[:user]

      # create a user to follow setup_user
      {:ok, follower} = @subject.new("jdoe@gmail.com", "John Doe", "jdog")
      follower = %{follower | id: UUID.uuid1()}

      # user `follower` follows `setup_user`
      setup_user = %@subject{} = @subject.toggle_follower(setup_user, follower)
      assert MapSet.member?(setup_user.followers, follower.id) == true

      # user `follower` unfollows  `setup_user`
      setup_user = %@subject{} = @subject.toggle_follower(setup_user, follower)
      refute MapSet.member?(setup_user.followers, follower.id) == true
    end

    test "toggle_following/2 will toggle user id of users being followed", user do
      setup_user = user[:user]

      # create a user for setup_user to follow
      {:ok, followed} = @subject.new("jdoe@gmail.com", "John Doe", "jdog")
      followed = %{followed | id: UUID.uuid1()}

      # user `follow` follows `setup_user`
      setup_user = %@subject{} = @subject.toggle_following(setup_user, followed)
      assert MapSet.member?(setup_user.following, followed.id) == true

      # user `follow` unfollows  `setup_user`
      setup_user = %@subject{} = @subject.toggle_following(setup_user, followed)
      refute MapSet.member?(setup_user.followers, followed.id) == true
    end
  end
end
