puts ENV

require 'typhoeus/adapters/faraday'

Github.configure do |config|
  config.adapter       = :typhoeus
  config.login         = ENV['GITHUB_USER']
  config.password      = ENV['GITHUB_PASSWORD']
  config.client_id     = ENV['GITHUB_CLIENT_ID']
  config.client_secret = ENV['GITHUB_CLIENT_SECRET']
end

Github.configure do |config|
  config.oauth_token = Github.oauth.create(scopes: %{public_repo}).token
end