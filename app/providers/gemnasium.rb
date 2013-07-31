class Gemnasium < Provider

  validates_presence_of :ruby?, :contains_gemfile?

  order 2
  link_url "https://gemnasium.com/:user/:repo_name"
  image_url "https://gemnasium.com/:user/:repo_name.png"

  private

  def ruby?
    language_is?(:ruby)
  end

  def contains_gemfile?
    repo.contents('/').any? { |file| file.name =~ /Gemfile/ }
  end

end