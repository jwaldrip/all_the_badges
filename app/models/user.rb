class User
  include ActiveModel::Model
  include Cacheable

  cache_keys :login

  attr_accessor :login

  class << self

    def find(login)
      self.new(login: login)
    end

  end

  def repos
    @repos ||= Repo.by_user self
  end

  def cache_key(*args)
    ([self.class.name, login] + args).compact.join('/')
  end

end