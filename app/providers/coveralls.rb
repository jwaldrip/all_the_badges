class Coveralls < Provider

  order 4
  link_url 'https://coveralls.io/r/:user/:repo_name?branch=:branch'
  image_url 'https://coveralls.io/repos/:user/:repo_name/badge.png?branch=:branch'
  creatable! link_url: 'https://coveralls.io/', image_url: 'coveralls_unknown.png'

  private

  def created?
    Rails.cache.fetch cache_key, expires_in: 60.minutes do
      Faraday.get("https://coveralls.io/r/#{user}/#{repo_name}?branch=#{branch}").status == 200
    end
  end

end