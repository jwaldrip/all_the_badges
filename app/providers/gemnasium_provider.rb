class GemnasiumProvider < Provider

  validates_presence_of :package_supported?, :language_supported?

  alt 'Dependencies'
  order 2
  link_url "https://gemnasium.com/:user_login/:repo_name"
  image_url "https://gemnasium.com/:user_login/:repo_name.png"
  creatable! link_url: 'https://gemnasium.com/:user_login', image_url: "gemnasium_inactive.png"

  private

  def language_supported?
    language_is?(:ruby) || language_is?(:javascript)
  end

  def package_supported?
    contains_bundle? || is_package?
  end

end