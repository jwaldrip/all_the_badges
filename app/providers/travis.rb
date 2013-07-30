class Travis < Provider

  order 2
  link_url 'https://travis-ci.org/:user/:repo_name'
  image_url 'https://travis-ci.org/:user/:repo_name.png?branch=:branch'
  creatable! link_url: 'http://travis-ci.org', image_url: 'travis_unknown.png'

  def created?
    Faraday.get("https://travis-ci.org/#{user}/#{repo_name}.png?branch=#{branch}").status == 200
  end


end