class Repo
  include ActiveModel::Model
  include SelectiveAttributes
  include Cacheable

  cache_keys :user, :name, :branch

  class << self

    def all_by_user(user)
      Rails.cache.fetch user.cache_key, expires_in: 60.minutes do
        Github.repos.list(user: user.login).map do |repo|
          find_or_initialize_by repo
        end
      end
    end

    def find(user, repo, attrs={})
      find_or_initialize_by attrs.merge login: user, repo: repo
    end

    def find_or_initialize_by(attrs={})
      attrs.reject! { |k, v| v.nil? }
      login, repo = attrs.delete(:login), attrs.delete(:repo)
      cache_key = User.new(login: login).cache_key(repo, attrs.to_param)
      Rails.cache.fetch cache_key, expires_in: 1.day do
        if attrs[:name].present?
          new(attrs)
        else
          new Github.repos.find(user: login, repo: repo).body.reverse_merge(attrs)
        end
      end
    end

  end

  attr_accessor :full_name, :name, :owner, :default_branch, :description, :html_url, :language
  attr_writer :branch

  def branch
    @branch || default_branch
  end

  def user
    @user ||= User.new owner
  end

  def contents(path)
    (@contents ||= {})[path] ||= Content.find(self, path)
  end

  def providers
    @providers = Provider.for_repo self
  end

  def to_s
    name
  end

end