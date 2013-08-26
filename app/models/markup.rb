class Markup
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  class << self

    attr_reader :_template

    def list
      base_dir = Rails.root.join 'app', 'markups'
      Dir.glob(base_dir.join '**', '*.rb').map do |markup|
        markup.gsub(/^#{base_dir}\/(.*)\.rb$/, "\\1").camelize.constantize
      end.select { |markup| markup.in? descendants }
    end

    def supported_by_language(lang)
      list.select do |markup|
        markup._languages.include?(:all) ||
          markup._languages.any? { |l| l == lang }
      end
    end

    def for_repo(repo, host: nil)
      supported_by_language(repo.language).sort_by(&:order).reduce({}) do |output, markup_klass|
        markup = repo.providers.map { |provider| markup_klass.for_provider provider, host: host }.join("\n")
        output.merge markup_klass.display_name => markup
      end
    end

    def for_provider(provider, host: host)
      new(provider: provider, host: host).output
    end

    def display_name
      @display_name || self.name.chomp('Markup')
    end

    def _languages
      @_languages ||= []
    end

    def _languages=(val)
      @_languages = val
    end

    def public_order
      @order
    end

    def method_missing(m, *args, &block)
      if respond_to? "public_#{m}"
        send "public_#{m}", *args, &block
      else
        super
      end
    end

    private

    def set_display_name(name = nil)
      @display_name = name
    end

    def languages(*langs)
      self._languages += langs.map { |lang| Language.new lang }
    end

    def template(content)
      SymbolConverter.replace! content
      class_eval <<-ruby
        def output
          "#{content.to_s.gsub(/"/, '\"')}".strip
        end
      ruby
    end

    def order(int)
      @order = int
    end

  end

  attr_accessor :provider, :host
  delegate :alt, :display_name, to: :provider, prefix: true
  template nil
  order 99

  def port
    URI.parse(host).port
  end

  def image_url
    provider_url provider: provider.slug, repo: provider.repo_name, user: provider.user_login, format: :png, host: host, port: port
  end

  def link_url
    provider_url provider: provider.slug, repo: provider.repo_name, user: provider.user_login, host: host, port: port
  end

end