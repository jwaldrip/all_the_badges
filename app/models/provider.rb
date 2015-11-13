class Provider
  include ActiveModel::Model
  include DefCache

  attr_accessor :repo
  delegate :branch, :is_package?, :contains_bundle?, :language_is?, :user, to: :repo
  delegate :name, to: :repo, prefix: true
  delegate :login, to: :user, prefix: true

  cache_method :created?, expires_in: 60.minutes, keys: [:user_login, :repo_name, :branch]

  validates_presence_of :raw_image_url, :raw_link_url

  InvalidProvider = Class.new(StandardError)

  class << self

    def from_slug(slug)
      (slug.camelize + 'Provider').constantize.tap do |const|
        raise InvalidProvider, "#{const} is not a valid #{name}" unless descendants.include? const
      end
    rescue NameError
      raise InvalidProvider, "Could not locate a matching constant for #{slug}"
    end

    def for_repo(repo)
      list.map do |provider|
        provider.new repo: repo
      end.select(&:valid?).sort_by(&:order)
    end

    def list
      base_dir = Rails.root.join 'app', 'providers'
      Dir.glob(base_dir.join '**', '*.rb').map do |provider|
        provider.gsub(/^#{base_dir}\/(.*)\.rb$/, "\\1").camelize.constantize
      end.select { |provider| provider.in? descendants }
    end

    private

    def image_url(url)
      SymbolConverter.replace! url
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def raw_image_url
          "#{url}"
        end
      RUBY
    end

    def link_url(url)
      SymbolConverter.replace! url
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def raw_link_url
          "#{url}"
        end
      RUBY
    end

    def creatable!(link_url: nil, image_url: nil)
      [link_url, image_url].each { |arg| SymbolConverter.replace! arg }
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def create_link_url
          "#{link_url}"
        end

        def create_image_url
          "#{image_url}"
        end
      RUBY
    end

    def display_name(name = nil)
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def display_name
          '#{name}'.present? ? '#{name}' : self.class.name.titleize
        end
      RUBY
    end

    def alt(string = nil)
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def alt
          '#{string}'
        end
      RUBY
    end

    def order(int)
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def order
          #{int}
        end
      RUBY
    end

  end

  display_name nil
  alt nil
  image_url nil
  link_url nil
  creatable!
  order 99

  def slug
    self.class.name.underscore.chomp '_provider'
  end

  def image_url
    created? ? raw_image_url : create_image_url
  end

  def link_url
    created? ? raw_link_url : create_link_url
  end

  private

  def created?
    http.get(raw_image_url).status == 200
  rescue URI::InvalidURIError
    false
  end

  def http
    @http ||= Faraday.new(ssl: { verify: false }) do |conn|
      conn.response :follow_redirects
      conn.adapter :net_http
    end
  end

end
