class Gemnasium < Provider

  validates_presence_of :ruby?, :contains_bundle?

  order 2
  link_url "https://gemnasium.com/:user/:repo_name"
  image_url "https://gemnasium.com/:user/:repo_name.png"
  creatable! link_url: 'https://gemnasium.com/:user', image_url: "gemnasium_inactive.png"

  private

  def ruby?
    language_is?(:ruby)
  end

end