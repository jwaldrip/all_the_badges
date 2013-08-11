class CoverallsProvider < Provider

  order 4
  link_url 'https://coveralls.io/r/:user_login/:repo_name?branch=:branch'
  image_url 'https://coveralls.io/repos/:user_login/:repo_name/badge.png?branch=:branch'
  creatable! link_url: 'https://coveralls.io/', image_url: 'coveralls_unknown.png'

end