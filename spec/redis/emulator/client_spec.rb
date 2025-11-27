require 'rails_helper'

RSpec.describe Redis::Emulator::Client do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:client) { described_class.new(cache: cache) }

  before do
    cache.clear
  end

  describe '#get and #set' do
    it 'sets and gets a value' do
      expect(client.set('key', 'value')).to eq('OK')
      expect(client.get('key')).to eq('value')
    end

    it 'returns nil for non-existent key' do
      expect(client.get('nonexistent')).to be_nil
    end

    it 'sets with expiration in seconds' do
      client.set('key', 'value', ex: 60)
      expect(client.get('key')).to eq('value')
    end

    it 'sets with expiration in milliseconds' do
      client.set('key', 'value', px: 60000)
      expect(client.get('key')).to eq('value')
    end

    it 'respects nx option (only set if not exists)' do
      client.set('key', 'value1')
      result = client.set('key', 'value2', nx: true)
      expect(result).to be_nil
      expect(client.get('key')).to eq('value1')
    end

    it 'respects xx option (only set if exists)' do
      result = client.set('key', 'value', xx: true)
      expect(result).to be_nil
      expect(client.get('key')).to be_nil
    end
  end

  describe '#del' do
    it 'deletes a single key' do
      client.set('key', 'value')
      expect(client.del('key')).to eq(1)
      expect(client.get('key')).to be_nil
    end

    it 'deletes multiple keys' do
      client.set('key1', 'value1')
      client.set('key2', 'value2')
      expect(client.del('key1', 'key2')).to eq(2)
    end

    it 'returns 0 for non-existent key' do
      expect(client.del('nonexistent')).to eq(0)
    end
  end

  describe '#exists' do
    it 'checks if key exists' do
      client.set('key', 'value')
      expect(client.exists('key')).to eq(1)
    end

    it 'returns 0 for non-existent key' do
      expect(client.exists('nonexistent')).to eq(0)
    end

    it 'counts multiple existing keys' do
      client.set('key1', 'value1')
      client.set('key2', 'value2')
      expect(client.exists('key1', 'key2')).to eq(2)
    end
  end

  describe '#expire' do
    it 'sets expiration on existing key' do
      client.set('key', 'value')
      expect(client.expire('key', 60)).to eq(1)
    end

    it 'returns 0 for non-existent key' do
      expect(client.expire('nonexistent', 60)).to eq(0)
    end
  end

  describe '#ttl' do
    it 'returns -2 for non-existent key' do
      expect(client.ttl('nonexistent')).to eq(-2)
    end

    it 'returns -1 for key without expiration' do
      client.set('key', 'value')
      expect(client.ttl('key')).to eq(-1)
    end
  end

  describe '#incr and #decr' do
    it 'increments a value' do
      expect(client.incr('counter')).to eq(1)
      expect(client.incr('counter')).to eq(2)
    end

    it 'decrements a value' do
      client.set('counter', '10')
      expect(client.decr('counter')).to eq(9)
    end
  end

  describe '#incrby and #decrby' do
    it 'increments by amount' do
      expect(client.incrby('counter', 5)).to eq(5)
      expect(client.incrby('counter', 3)).to eq(8)
    end

    it 'decrements by amount' do
      client.set('counter', '10')
      expect(client.decrby('counter', 3)).to eq(7)
    end
  end

  describe '#mget and #mset' do
    it 'gets multiple values' do
      client.set('key1', 'value1')
      client.set('key2', 'value2')
      expect(client.mget('key1', 'key2')).to eq(['value1', 'value2'])
    end

    it 'sets multiple values' do
      expect(client.mset('key1', 'value1', 'key2', 'value2')).to eq('OK')
      expect(client.get('key1')).to eq('value1')
      expect(client.get('key2')).to eq('value2')
    end
  end

  describe '#setex' do
    it 'sets value with expiration' do
      expect(client.setex('key', 60, 'value')).to eq('OK')
      expect(client.get('key')).to eq('value')
    end
  end

  describe '#setnx' do
    it 'sets value only if not exists' do
      expect(client.setnx('key', 'value')).to eq(1)
      expect(client.setnx('key', 'value2')).to eq(0)
      expect(client.get('key')).to eq('value')
    end
  end

  describe '#getset' do
    it 'sets new value and returns old value' do
      client.set('key', 'old')
      expect(client.getset('key', 'new')).to eq('old')
      expect(client.get('key')).to eq('new')
    end
  end

  describe '#append' do
    it 'appends to existing value' do
      client.set('key', 'hello')
      length = client.append('key', ' world')
      expect(length).to eq(11)
      expect(client.get('key')).to eq('hello world')
    end

    it 'creates new key if not exists' do
      length = client.append('key', 'hello')
      expect(length).to eq(5)
      expect(client.get('key')).to eq('hello')
    end
  end

  describe '#strlen' do
    it 'returns length of value' do
      client.set('key', 'hello')
      expect(client.strlen('key')).to eq(5)
    end

    it 'returns 0 for non-existent key' do
      expect(client.strlen('nonexistent')).to eq(0)
    end
  end

  describe '#flushdb' do
    it 'clears all keys' do
      client.set('key1', 'value1')
      client.set('key2', 'value2')
      expect(client.flushdb).to eq('OK')
      expect(client.get('key1')).to be_nil
      expect(client.get('key2')).to be_nil
    end
  end

  describe '#ping' do
    it 'returns PONG' do
      expect(client.ping).to eq('PONG')
    end

    it 'returns message if provided' do
      expect(client.ping('hello')).to eq('hello')
    end
  end

  describe '#info' do
    it 'returns server info' do
      info = client.info
      expect(info).to include('Redis Emulator')
    end
  end

  describe '#connected?' do
    it 'returns true' do
      expect(client.connected?).to be true
    end
  end

  describe '#close' do
    it 'returns true' do
      expect(client.close).to be true
    end
  end
end
