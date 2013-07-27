module Cacheable
  extend ActiveSupport::Concern

  def cache_key(*args)
    values = self.class.cache_keys.map do |key|
      send(key) || '*'
    end
    ([self.class.name] + values + args).compact.join('/')
  end

  module ClassMethods

    def cache_keys(*keys)
      @cache_keys.present? ? @cache_keys : (@cache_keys = keys)
    end

  end

end