class BadgeFury < Provider

  validates_presence_of :project_type

  order 1
  link_url "https://badge.fury.io/:project_type/:package_name"
  image_url "https://badge.fury.io/:project_type/:package_name.png"

  private

  def package_name
    repo_name
  end

  def project_type
    [:rb, :js, :py].find { |type| send "#{type}?" }
  end

  def rb?
    language_is?(:ruby) && is_package?
  end

  def js?
    language_is?(:javascript) && is_package?
  end

  def py?
    language_is?(:python) && is_package?
  end

end