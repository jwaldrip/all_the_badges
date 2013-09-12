class CachedImage
  include ActionView::Helpers::AssetUrlHelper
  include DefCache
  cache_method :body, keys: [:repo_name, :repo_last_sha, :provider_display_name]

  class << self

    def fetch(provider: nil)
      new(provider).body
    end

  end

  attr_reader :provider
  delegate :image_url, :repo, to: :provider
  delegate :display_name, to: :provider, prefix: true
  delegate :name, :last_sha, to: :repo, prefix: true

  def initialize(provider)
    raise ArgumentError, 'provider must be a Provider' unless provider.is_a? Provider
    @provider = provider
  end

  def body
    response.body
  rescue URI::InvalidURIError
    File.read File.join 'app', 'assets', 'images', image_url
  end

  private

  def response
    http.get image_url
  end

  def http
    @http ||= Faraday.new do |conn|
      conn.response :follow_redirects
      conn.adapter :net_http
    end
  end

end