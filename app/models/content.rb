class Content
  include ActiveModel::Model
  include SelectiveAttributes

  class << self

    def find(repo, path)
      response = Rails.cache.fetch repo.cache_key(path), expires_in: 60.minutes do
        find_without_cache(repo, path)
      end
      case response
      when Array
        new_collection_from_response(response, repo)
      when Hash
        new response
      end
    rescue Github::Error::NotFound
      []
    end

    def find_without_cache(repo, path)
      Github.repos.contents.find(repo.user.login, repo.name, path, ref: repo.branch).body
    end

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
  end

  def reload
    self.replace self.class.find repo, path
  end

  def replace(other_object)
    vars = [other_object, self].map(&:instance_variables).flatten
    vars.each do |var|
      new_value = other_object.instance_variable_get var
      self.instance_variable_set var, new_value
    end
  end

end