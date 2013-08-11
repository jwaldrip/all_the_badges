class TravisProvider < Provider

  order 3
  link_url 'https://travis-ci.org/:user_login/:repo_name'
  image_url 'https://travis-ci.org/:user_login/:repo_name.png?branch=:branch'
  creatable! link_url: 'http://travis-ci.org', image_url: 'travis_unknown.png'

end