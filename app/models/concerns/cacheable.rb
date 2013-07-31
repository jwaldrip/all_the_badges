module Cacheable
  extend ActiveSupport::Concern

  included do
    class_attribute :_cache_keys
  end

  def cache_key(*args)
    values = self.class.cache_keys.map do |key|
      send(key) || '*'
    end
    ([self.class.name] + values + args).select(&:present?).join('/')
  end

  module ClassMethods

    def cache_keys(*keys)
      _cache_keys.present? ? _cache_keys : (self._cache_keys = keys)
    end

  end

end