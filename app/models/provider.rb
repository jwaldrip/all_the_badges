class Provider
  include ActiveModel::Model
  include Cacheable

  cache_keys :user_login, :repo_name, :branch

  attr_accessor :repo
  delegate :branch, :is_package?, :contains_bundle?, :language_is?, :user, to: :repo
  delegate :name, to: :repo, prefix: true
  delegate :login, to: :user, prefix: true

  validates_presence_of :image_url, :link_url

  InvalidProvider = Class.new(StandardError)

  class << self

    def image_url(url)
      convert_symbols! url
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def raw_image_url
          "#{url}"
        end
      RUBY
    end

    def link_url(url)
      convert_symbols! url
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def raw_link_url
          "#{url}"
        end
      RUBY
    end

    def creatable!(link_url: nil, image_url: nil)
      [link_url, image_url].each { |arg| convert_symbols! arg }
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def create_link_url
          "#{link_url}"
        end

        def create_image_url
          "#{image_url}"
        end
      RUBY
    end

    def from_slug(slug)
      slug.camelize.constantize.tap do |const|
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

    def display_name(name = nil)
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def display_name
          '#{name}'.present? ? '#{name}' : self.class.name.titleize
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

    private

    def convert_symbols!(string)
      string.gsub!(/:(?<m>[_a-z]+[_a-zA-Z1-9]*)/) { ['#{', $~[:m], '}'].join }
    rescue
      string
    end

  end

  display_name nil
  image_url nil
  link_url nil
  creatable!
  order 99

  def slug
    self.class.name.underscore
  end

  def image_url
    created? ? raw_image_url : create_image_url
  end

  def link_url
    created? ? raw_link_url : create_link_url
  end

  private

  def created?
    Rails.cache.fetch cache_key, expires_in: 60.minutes do
      Faraday.get(raw_image_url).status == 200
    end
  end

end