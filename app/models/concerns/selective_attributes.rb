module SelectiveAttributes
  extend ActiveSupport::Concern

  included do
    if ancestors.include? ActiveRecord::Base
      define_singleton_method(:fields) do
        column_names
      end
    end
  end

  def initialize(params={})
    super extract_valid_attributes params
  end

  delegate :extract_valid_attributes, to: :class

  module ClassMethods

    def extract_valid_attributes(attrs={})
      attrs = attrs.to_hash.with_indifferent_access
      valid_keys = (attrs || {}).keys.select do |attr|
        method_defined?("#{attr}=") || fields.include?(attr.to_s)
      end
      attrs.slice *valid_keys
    end

    def fields
      []
    end

  end

end