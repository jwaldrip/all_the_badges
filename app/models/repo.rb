require 'active_model'

class Repo
  include ActiveModel::Model
  include SelectiveAttributes

  class << self

    def all_by_user(user)
      @repos ||= Github.repos.list(user: user).map { |repo| new(repo) }
    end

    def find(user, repo, attrs={})
      new Github.repos.find(user: user, repo: repo).body.reverse_merge(attrs)
    end

  end

  attr_accessor :full_name, :name, :owner, :default_branch
  attr_writer :branch

  def branch
    @branch || default_branch
  end

  def user
    @user ||= owner.login
  end

  def contents(path)
    (@contents ||= {})[path] ||= Content.find(self, path, ref: branch)
  end

  def inspect
    to_s
  end

  def to_s
    "#<Repo (#{full_name})>"
  end

end