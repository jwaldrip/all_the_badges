class MarkdownMarkup < Markup

  languages :all

  template <<-template
    [![:provider_alt](:image_url)](:link_url)
  template

end