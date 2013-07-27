module SelectiveAttributes
  extend ActiveSupport::Concern

  included do
    attr_reader :_raw
  end

  def initialize(attrs={})
    @_raw = attrs
    super attrs.slice *attrs.keys.select { |attr| respond_to? "#{attr}=" }
  end

end