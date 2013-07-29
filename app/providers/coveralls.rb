class Coveralls < Provider

  link_url 'https://coveralls.io/r/:user/:repo_name?branch=:branch'
  image_url 'https://coveralls.io/repos/:user/:repo_name/badge.png?branch=:branch'

end