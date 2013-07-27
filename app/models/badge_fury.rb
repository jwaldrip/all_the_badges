class BadgeFury < Provider

  validates_presence_of :project_type

  def package_name
    repo.name
  end

  def link_url
    "https://badge.fury.io/#{project_type}/#{package_name}"
  end

  def image_url
    "https://badge.fury.io/#{project_type}/#{package_name}@2x.png"
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