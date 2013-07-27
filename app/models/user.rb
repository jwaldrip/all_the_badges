class User
  include ActiveModel::Model

  attr_accessor :login

  class << self

    def find(login)
      self.new(login: login)
    end

  end

  def repos
    @repos ||= Repo.by_user login
  end

end