class CoverallsProvider < Provider

  order 4
  link_url 'https://coveralls.io/r/:user/:repo_name?branch=:branch'
  image_url 'https://coveralls.io/repos/:user/:repo_name/badge.png?branch=:branch'
  creatable! link_url: 'https://coveralls.io/', image_url: 'coveralls_unknown.png'

end