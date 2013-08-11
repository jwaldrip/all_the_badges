require 'spec_helper'

describe Cacheable do

  let(:klass) do
    klass = Class.new do
      include Cacheable
      cache_keys(:lorem, :ipsum).each do |method|
        define_method(method) { "value for #{method}" }
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

  describe '.cache_methods' do
    let(:options){ { expire_in: 5.minutes } }
    it 'should call .cache_method with each method specified with options' do
      [:foo, :bar, :baz].each do |method|
        expect(klass).to receive(:cache_method).with(method, options)
      end
      klass.cache_methods :foo, :bar, :baz, options
    end
  end

  describe '.cache_method' do
    let(:options){ { expire_in: 5.minutes } }
    before(:each) do
      klass.send :define_method, :foo do |a=1, b=2, c=3|
        "Pity the foo with #{a}, #{b} and #{c}"
      end
      klass.cache_method :foo, options
    end

    it 'should define a method with cache' do
      expect(klass).to receive(:method_added).with :lorem
      expect(klass).to receive(:method_added).with :lorem_with_cache
      expect(klass).to receive(:method_added).with :lorem_without_cache
      klass.cache_method :lorem
    end

    context 'the methods defined' do

      describe '#foo_with_cache' do
        it 'should cache the result with options' do
          expect(Rails.cache).to receive(:fetch).with instance.cache_key('foo'), options
          instance.foo_with_cache
        end

        it 'should cache miss to the original method' do
          expect(instance).to receive(:foo_without_cache)
          instance.foo_with_cache
        end
      end

      describe '#foo_without_cache' do
        it 'should not call cache' do
          expect(Rails.cache).to_not receive(:fetch)
          instance.foo_without_cache
        end

        it 'should be the original method' do
          instance.foo_without_cache.should eq "Pity the foo with 1, 2 and 3"
        end
      end

      describe '#foo' do
        it 'should be aliased to the cached method' do
          expect(Rails.cache).to receive(:fetch).with instance.cache_key('foo'), options
          instance.foo
        end
      end

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