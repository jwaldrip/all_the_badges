class User < ActiveRecord::Base
  include SelectiveAttributes
  include Cacheable

  cache_keys :login

  class << self

    def find_by_login(login)
      find_by(login: login) || fetch_user(login)
    end

    private

    def fetch_user(login)
      create extract_valid_attributes Github.users.find(user: login).body
    end

  end

  has_many :local_repos, class_name: 'Repo', foreign_key: :user_id
  has_many :repos, ->(user) { update_from_github(user) }

  def github_repos
    @github_repos ||= Rails.cache.fetch cache_key, expires_in: 60.minutes do
      Github.repos.list(user: login, per_page: 1000).to_a
    end
  end

end
