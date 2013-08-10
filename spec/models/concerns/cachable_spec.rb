require 'spec_helper'

describe Cacheable do

  let(:klass) do
    klass = Class.new do
      include Cacheable
      cache_keys(:lorem, :ipsum).each do |method|
        define_method(method) { SecureRandom.hex }
      end
    end
    stub_const 'CacheableClass', klass
  end

  let(:instance) { klass.new }

  describe '.cache_keys' do
    it 'should change the value of cache keys' do
      keys = [:foo, :bar, :baz]
      expect { klass.cache_keys *keys }.to change { klass._cache_keys }.to include *keys
    end

    it 'should keep existing keys' do
      existing_keys = [:uno, :dos]
      klass.cache_keys *existing_keys
      keys = [:foo, :bar, :baz]
      expect { klass.cache_keys *keys }.to change { klass._cache_keys }.to include *existing_keys
    end
  end

  describe '#cache_key' do
    it 'should call each method' do
      klass._cache_keys.each do |method|
        expect(instance).to receive(method).and_call_original
      end
      instance.cache_key
    end

    context 'given an invalid method' do
      it 'should raise an error' do
        klass.cache_keys :invalid
        expect { instance.cache_key }.to raise_error NoMethodError
      end
    end

    context 'given an instance returns nil' do
      it 'should return a star for that method' do
        allow(instance).to receive(klass._cache_keys.first).and_return nil
        instance.cache_key.should match /^#{klass.name}\/\*/
      end
    end

    context 'given args' do
      context 'that are not nil' do
        it 'should add them' do
          instance.cache_key('foo_arg', 'bar_arg').should include 'foo_arg', 'bar_arg'
        end
      end

      context 'that are nil' do
        it 'should not add a star or empty value' do
          instance.cache_key(nil).should_not include '//', '*'
        end
      end
    end

  end
end