class BadgeFury < Provider

  validates_presence_of :project_type

  link_url "https://badge.fury.io/:project_type/:package_name"
  image_url "https://badge.fury.io/:project_type/:package_name@2x.png"

  def package_name
    repo_name
  end

  def project_type
    [:rb, :js, :py].find { |type| send "#{type}?" }
  end

  private

  def rb?
    repo.contents('/').find { |file| file.name =~ /\.gemspec/ }
  end

  def js?
    repo.contents('/').find { |file| file.name =~ /package\.json/ }
  end

  def py?
    repo.contents('/').find { |file| file.name =~ /setup\.py/ }
  end

end