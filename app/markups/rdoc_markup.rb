class RdocMarkup < Markup

  languages :ruby

  template '{<img src=":image_url" alt=":provider_alt" />}[:link_url]'

end