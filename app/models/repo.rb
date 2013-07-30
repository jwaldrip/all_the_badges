class Repo
  include ActiveModel::Model
  include SelectiveAttributes
  include Cacheable

  cache_keys :user, :name, :branch

  class << self

    def all_by_user(user)
      cache_key = user.cache_key
      @repos ||= Rails.cache.fetch cache_key do
        all_by_user_without_cache(user)
      end
    end

    def all_by_user_without_cache(user)
      Github.repos.list(user: user.login).map { |repo| new(repo) }
    end

    def find(user, repo, attrs={})
      cache_key = [:repo, user, repo, attrs.to_param].compact.join('/')
      Rails.cache.fetch cache_key, expires_in: 60.minutes do
        new find_without_cache(user, repo, attrs)
      end
    end

    def find_without_cache(user, repo, attrs={})
      Github.repos.find(user: user, repo: repo).body.reverse_merge(attrs)
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