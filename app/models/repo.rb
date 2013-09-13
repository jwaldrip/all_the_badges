class Repo < ActiveRecord::Base
  include SelectiveAttributes
  include DefCache

  cache_method :commits, expires_in: 1.hour, keys: [:user_login, :name, :branch]
  cache_method :build_status, expires_in: 1.hour, keys: :last_sha

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

    def find_or_fetch(user: nil, name: nil, branch: nil)
      (find_by(user_id: user.try(:id), name: name) || fetch(user: user, name: name)).tap do |instance|
        instance.branch = branch
      end
    end

    private

    def fetch(user: nil, name: nil)
      create extract_valid_attributes Github.repos.get user: user.login, repo: name
    end

  end

  default_scope { order(name: :asc) }

  belongs_to :user
  attr_writer :branch
  delegate :login, to: :user, prefix: true, allow_nil: true
  before_save :determine_if_is_package
  before_save :determine_if_contains_bundle

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
    @providers ||= Provider.for_repo self
  end

  def language
    Language.new read_attribute :language
  end

  def language_is?(lang)
    language == lang
  end

  def commits
    Github.repos.commits.list(user_login, name).to_a
  rescue Github::Error::ServiceError
    []
  end

  def build_status
    Github.repos.statuses.list(user_login, name, last_sha).sort_by(&:updated_at).last.state
  rescue NoMethodError, ArgumentError
    :unknown
  end

  def last_sha
    self.commits.first.sha if commits.present?
  end

  private

  def determine_if_is_package
    self.is_package = contains_gemspec? || contains_package_json? || contains_setup_script?
    true
  end

  def determine_if_contains_bundle
    self.contains_bundle = contains_gemfile? || contains_node_modules?
    true
  end

  def contains_gemspec?
    language_is?(:ruby) && contents('/').any? { |file| file.name =~ /\.gemspec/ }
  end

  def contains_package_json?
    language_is?(:javascript) && contents('/').any? { |file| file.name =~ /package\.json/ }
  end

  def contains_setup_script?
    language_is?(:python) && contents('/').any? { |file| file.name =~ /setup\.py/ }
  end

  def contains_gemfile?
    contents('/').any? { |file| file.name =~ /Gemfile/ }
  end

  def contains_node_modules?
    language_is?(:javascript) && contents('/node_modules').present?
  rescue Github::Error::NotFound
    false
  end

end