class User
  include ActiveModel::Model
  include Cacheable
  include SelectiveAttributes

  cache_keys :login

  attr_accessor :login

  class << self

    def find(login)
      self.new(login: login)
    end

  end

  def repos
    @repos ||= Repo.all_by_user self
  end

  def cache_key(*args)
    ([self.class.name, login] + args).compact.join('/')
  end

  def to_s
    login
  end

end