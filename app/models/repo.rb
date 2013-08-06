class Repo < ActiveRecord::Base
  include SelectiveAttributes
  include Cacheable

  cache_keys :user, :name, :branch

  class << self

    def update_from_github(user)
      user.github_repos.each do |remote_repo|
        attributes            = extract_valid_attributes remote_repo.to_hash
        local_repo            = user.local_repos.find { |r| r.id == remote_repo.id } || create(attributes)
        local_repo.attributes = attributes
        local_repo.save if local_repo.changed?
      end
      all
    end

  end

  belongs_to :user
  attr_writer :branch

  def branch
    @branch || default_branch
  end

  def owner=(owner)
    self.user = User.find_by_login(owner['login']) unless self.user_id.present?
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