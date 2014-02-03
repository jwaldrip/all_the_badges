class User < ActiveRecord::Base
  include SelectiveAttributes
  include DefCache

  cache_method :github_repos, keys: [:login], expires_in: 60.minutes

  class << self

    def find_or_fetch(login: nil)
      find_by("login = lower(?)", login) || fetch(login: login)
    end

    private

    def fetch(login: nil)
      create extract_valid_attributes Github.users.find(user: login).body
    end

  end

  has_many :local_repos, class_name: 'Repo', foreign_key: :user_id
  has_many :repos, ->(user) { update_from_github(user) }

  def github_url
    "https://github.com/#{login}"
  end

  def to_param
    login
  end

  def github_repos
    Github.repos.list(user: login, per_page: 1000).to_a
  end

end
