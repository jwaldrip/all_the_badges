class Provider
  include ActiveModel::Model

  attr_accessor :repo
  delegate :branch, :user, to: :repo
  delegate :name, to: :repo, prefix: true

  validates_presence_of :image_url, :link_url

  class << self

    def image_url(url)
      convert_symbols! url
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def image_url
          self.created? ? "#{url}" : create_image_url
        end
      RUBY
    end

    def link_url(url)
      convert_symbols! url
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def link_url
          self.created? ? "#{url}" : create_link_url
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

    def for_repo(repo)
      Dir.glob(Rails.root.join 'app', 'providers', '**', '*.rb').map do |provider|
        klass = File.basename(provider, '.rb').camelize.constantize
        klass.new repo: repo
      end.select(&:valid?).sort_by(&:order)
    end

    def display_name(name = nil)
      (@display_name ||= name) || self.name.titleize
    end

    def order(int = nil)
      (@order ||= int) || 0
    end

    private

    def convert_symbols!(string)
      string.gsub!(/:(?<m>[_a-z]+[_a-zA-Z1-9]*)/) { ['#{', $~[:m], '}'].join }
    rescue
      string
    end

  end

  image_url nil
  link_url nil
  creatable!

  def created?
    true
  end

  def display_name
    self.class.display_name
  end

  def slug
    self.class.name.underscore
  end

  def order
    self.class.order
  end

end