module Cacheable
  extend ActiveSupport::Concern

  included do
    class_attribute :_cache_keys
    self._cache_keys = []
  end

  module ClassMethods

    def cache_keys(*keys)
      self._cache_keys += keys
    end

    def cache_methods(*methods)
      options = methods.extract_options!
      methods.each { |m| cache_method m, options }
    end

    def cache_method(method, options={})
      cached_target, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
      define_method("#{cached_target}_with_cache#{punctuation}") do |*args, &block|
        Rails.cache.fetch cache_key("#{method}", *args), options do
          send "#{cached_target}_without_cache#{punctuation}", *args, &block
        end
      end
      alias_method_chain method, :cache
    end

  end

  def cache_key(*args)
    values = self._cache_keys.map do |key|
      send(key) || '*'
    end
    ([self.class.name] + values + args).select(&:present?).join('/')
  end

end