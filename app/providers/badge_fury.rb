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
    repo.language.to_s.downcase == 'ruby'
  end

  def js?
    repo.language.to_s.downcase == 'javascript'
  end

  def py?
    repo.language.to_s.downcase == 'python'
  end

end