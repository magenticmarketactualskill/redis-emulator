require "test_helper"

class Redis::EmulatorTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert Redis::Emulator::VERSION
  end
end
