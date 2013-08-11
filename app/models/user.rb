class User < ActiveRecord::Base
  include SelectiveAttributes
  include Cacheable

  cache_keys :login

  class << self

    def find_or_fetch(login: nil)
      find_by(login: login) || fetch(login: login)
    end

    private

    def fetch(login: nil)
      create extract_valid_attributes Github.users.find(user: login).body
    end

  end

  has_many :local_repos, class_name: 'Repo', foreign_key: :user_id
  has_many :repos, ->(user) { update_from_github(user) }

  def github_url
    "http://github.com/#{login}"
  end

  def github_repos
    @github_repos ||= Rails.cache.fetch cache_key, expires_in: 60.minutes do
      Github.repos.list(user: login, per_page: 1000).to_a
    end
  end

end
