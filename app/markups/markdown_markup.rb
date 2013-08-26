class MarkdownMarkup < Markup

  languages :all
  order 1

  template <<-template
    [![:provider_alt](:image_url)](:link_url)
  template

end