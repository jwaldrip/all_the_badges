class BadgeFury < Provider

  validates_presence_of :project_type

  order 1
  link_url "https://badge.fury.io/:project_type/:package_name"
  image_url "https://badge.fury.io/:project_type/:package_name.png"

  def package_name
    repo_name
  end

  def project_type
    [:rb, :js, :py].find { |type| send "#{type}?" }
  end

  private

  def rb?
    repo.language.downcase == 'ruby'
  end

  def js?
    repo.language.downcase == 'javascript'
  end

  def py?
    repo.language.downcase == 'python'
  end

end