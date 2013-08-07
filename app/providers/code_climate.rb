require 'net/http'

class CodeClimate < Provider

  validates_presence_of :ruby?

  order 5
  link_url "https://codeclimate.com/github/:user/:repo_name"
  image_url "https://codeclimate.com/github/:user/:repo_name.png"
  creatable! link_url: 'https://codeclimate.com/github/signup?name=:user%2F:repo_name', image_url: 'code_climate_unknown.png'

  private

  def ruby?
    language_is? :ruby
  end

end