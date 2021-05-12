require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  test "should create with nothing" do
    transaction = Transaction.new
    assert transaction.save
  end
end
