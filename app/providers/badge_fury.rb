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
    language_is?(:ruby) && contains_gemspec?
  end

  def contains_gemspec?
    repo.contents('/').any? { |file| file.name =~ /\.gemspec/ }
  end

  def js?
    language_is?(:javascript) && contains_package_json?
  end

  def contains_package_json?
    repo.contents('/').any? { |file| file.name =~ /package\.json/ }
  end

  def py?
    language_is?(:python) && contains_setup_script?
  end

  def contains_setup_script?
    repo.contents('/').any? { |file| file.name =~ /setup\.py/ }
  end

end