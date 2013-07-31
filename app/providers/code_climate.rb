require 'net/http'

class CodeClimate < Provider

  validates_presence_of :ruby?

  order 4
  link_url "https://codeclimate.com/github/:user/:repo_name"
  image_url "https://codeclimate.com/github/:user/:repo_name.png"
  creatable! link_url: 'https://codeclimate.com/github/signup?name=:user%2F:repo_name', image_url: 'code_climate_unknown.png'

  def created?
    Rails.cache.fetch cache_key, expires_in: 60.minutes do
      Faraday.get("https://codeclimate.com/github/#{user}/#{repo_name}").status == 200
    end
  end

  def ruby?
    repo.language.to_s.downcase == 'ruby'
  end

end