class Language < String

  def initialize(string)
    super string.to_s.downcase.parameterize('_')
  end

  def ==(other_language)
    other_language = self.class.new(other_language) unless other_language.is_a? self.class
    super other_language
  end

end