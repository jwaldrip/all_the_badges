require 'net/http'

class CodeClimate < Provider

  validates_presence_of :ruby?

  order 4
  link_url "https://codeclimate.com/github/:user/:repo_name"
  image_url "https://codeclimate.com/github/:user/:repo_name.png"
  creatable! link_url: 'https://codeclimate.com/github/signup?name=:user%2F:repo_name', image_url: 'code_climate_unknown.png'

  def created?
    Faraday.get("https://codeclimate.com/github/#{user}/#{repo_name}").status == 200
  end

  def ruby?
    repo.language.downcase == 'ruby'
  end

end