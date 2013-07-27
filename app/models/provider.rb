class Provider
  include ActiveModel::Model

  attr_accessor :repo
  delegate :branch, :user, to: :repo

  def image_url
    raise NotImplementedError
  end

  def link_url
    raise NotImplementedError
  end

end