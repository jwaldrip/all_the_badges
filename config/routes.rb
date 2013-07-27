Siac::Application.routes.draw do
  root to: 'users#index'
  get '/:user' => 'users#show'
  get '/:user/:repo' => 'repos#show'
  get '/:user/:repo/:provider' => 'providers#show'
end
