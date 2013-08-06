module SelectiveAttributes
  extend ActiveSupport::Concern

  included do
    attr_reader :_raw
  end

  def initialize(params={})
    params = ActionController::Parameters.new extract_valid_attributes params
    params.permit!
    super params
  end

  delegate :extract_valid_attributes, to: :class

  module ClassMethods

    def extract_valid_attributes(attrs={})
      valid_keys = (attrs || {}).keys.select do |attr|
        begin
          method_defined?("#{attr}=") || column_names.include?(attr.to_s)
        rescue NoMethodError
          false
        end
      end
      attrs.slice *valid_keys
    end

  end

end