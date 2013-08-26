class RdocMarkup < Markup

  languages :ruby
  order 3

  template '{<img src=":image_url" alt=":provider_alt" />}[:link_url]'

end