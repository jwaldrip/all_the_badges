class Gemnasium < Provider

  validates_presence_of :ruby?, :contains_gemfile?

  order 2
  link_url "https://gemnasium.com/:user/:repo_name"
  image_url "https://gemnasium.com/:user/:repo_name.png"
  creatable! link_url: 'https://gemnasium.com/:user', image_url: "gemnasium_inactive.png"

  private

  def ruby?
    language_is?(:ruby)
  end

  def created?
    Rails.cache.fetch cache_key, expires_in: 60.minutes do
      Faraday.get("https://gemnasium.com/#{user}/#{repo_name}.png").status == 200
    end
  end

  def contains_gemfile?
    repo.contents('/').any? { |file| file.name =~ /Gemfile/ }
  end

end