class Content
  include ActiveModel::Model
  include SelectiveAttributes

  class << self
    include DefCache
    cache_method :find, expires_in: 60.minutes

    def find(repo, path)
      response = Github.repos.contents.find(repo.user_login.to_s, repo.name.to_s, path, ref: repo.branch.to_s).body
      case response
      when Array
        new_collection_from_response response, repo
      when Hash
        new_instance_from_response response, repo
      end
    rescue Github::Error::NotFound
      []
    end

    private

    def new_collection_from_response(response, repo)
      response.map { |file| new_instance_from_response file, repo }
    end

    def new_instance_from_response(response, repo)
      new response.merge repo: repo
    end

  end

  attr_accessor :repo, :sha, :path, :name
  attr_writer :content

  def read
    reload unless @content
    Base64.decode64 @content
  rescue NoMethodError
    nil
  end

  def reload
    self.replace self.class.find repo, path
  end

  def replace(other_object)
    self.instance_variables.each { |var| remove_instance_variable var}
    other_object.instance_variables.each do |var|
      new_value = other_object.instance_variable_get var
      self.instance_variable_set var, new_value
    end
  end

end