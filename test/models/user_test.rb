require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should not save user without full_name" do
    user = User.new
    assert_not user.save
  end

  test "is offline" do
    user = User.new
    user.last_seen = nil
    assert_not user.online?

    user.last_seen =  Time.now - 11.minutes
    assert_not user.online?
  end

  test "is online" do
    user = User.new
    user.last_seen = Time.now
    assert user.online?

    user.last_seen =  Time.now - 5.minutes
    assert user.online?

    user.last_seen = Time.now - 9.minutes - 59.seconds
    assert user.online?
  end
end
