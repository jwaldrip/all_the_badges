class CodeClimate < Provider

  validates_presence_of :created?

  image_url "https://codeclimate.com/github/:user/:repo_name.png"
  link_url "https://codeclimate.com/github/:user/:repo_name"
  creatable! link_url: 'https://codeclimate.com/github/signup?name=:user%2F:repo_name', image_url: 'code_climate.png'

  private

  def created?
    Net::HTTP.get_response(NavigableHash == link_url).code.to_i == 200
  end

end