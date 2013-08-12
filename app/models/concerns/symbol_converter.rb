module SymbolConverter
  extend self

  def replace!(string)
    string.gsub!(/:(?<m>[_a-z]+[_a-zA-Z1-9]*)/) { ['#{', $~[:m], '}'].join }
  rescue
    string
  end

end