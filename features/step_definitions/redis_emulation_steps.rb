Given('I have a Redis Emulator client') do
  @cache = ActiveSupport::Cache::MemoryStore.new
  @client = Redis::Emulator::Client.new(cache: @cache)
  @cache.clear
end

When('I set {string} to {string}') do |key, value|
  @client.set(key, value)
end

Then('I should be able to get {string} from {string}') do |expected_value, key|
  actual_value = @client.get(key)
  expect(actual_value).to eq(expected_value)
end

When('I delete {string}') do |key|
  @client.del(key)
end

Then('{string} should not exist') do |key|
  expect(@client.exists(key)).to eq(0)
end

Then('{string} should exist') do |key|
  expect(@client.exists(key)).to eq(1)
end

When('I increment {string}') do |key|
  @client.incr(key)
end

Then('{string} should equal {int}') do |key, expected_value|
  actual_value = @client.get(key)
  expect(actual_value).to eq(expected_value)
end

When('I set multiple keys:') do |table|
  args = []
  table.hashes.each do |row|
    args << row['key']
    args << row['value']
  end
  @client.mset(*args)
end

Then('getting multiple keys {string} should return {string}') do |keys_str, values_str|
  keys = keys_str.split(',')
  expected_values = values_str.split(',')
  actual_values = @client.mget(*keys)
  expect(actual_values).to eq(expected_values)
end

When('I set {string} to {string} with expiration of {int} seconds') do |key, value, seconds|
  @client.setex(key, seconds, value)
end
