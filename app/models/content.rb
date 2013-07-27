class Content
  include ActiveModel::Model
  include SelectiveAttributes

  class << self

    def find(repo, path, options={})
      response = Github.repos.contents.find(repo.user, repo.name, path, options).body
      case response
      when Array
        new_collection_from_response(response, repo)
      when Hash
        new response
      end
    end

    def new_collection_from_response(response, repo)
      response.map { |file| new_instance_from_response file, repo }
    end

    def new_instance_from_response(response, repo)
      new response.merge repo: repo
    end

  end

  attr_accessor :repo
  attr_writer :content, :sha

  def read
    reload unless @content
    Base64.decode64 @content
  end

  def reload
    self.replace Github.repos.contents.find repo, ref: sha
  end

end