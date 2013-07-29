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
          "#{url}"
        end
      RUBY
    end

    def link_url(url)
      convert_symbols! url
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def link_url
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

  def creatable?
    create_link_url.present?
  end

end