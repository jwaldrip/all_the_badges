AllTheBadges::Application.routes.draw do
  root to: 'home#show'
  post '/' => 'find#create', as: :find
  get '/:user' => 'users#show', as: :user
  get '/:user/:repo' => 'repos#show', as: :repo
  get '/:user/:repo/:provider' => 'providers#show', as: :provider
end
