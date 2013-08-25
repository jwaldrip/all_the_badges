class ProvidersController < ApplicationController

  def show
    @provider = provider_class.new repo: repo
    respond_to do |format|
      format.png { render_image }
      format.html { redirect_to_provider }
    end
  end

  private

  def render_image
    expires_in 0.seconds, public: false, must_revalidate: true
    response.cache_control.replace(max_age: 10.seconds, public: false, must_revalidate: true)
    image = CachedImage.fetch(provider: @provider)
    render text: image, content_type: 'image/png', stream: true
  end

  def redirect_to_provider
    redirect_to @provider.link_url
  end

  def repo
    @repo ||= Repo.find_or_fetch user: user, name: params[:repo], branch: branch_from_referer
  end

  def user
    @user ||= User.find_or_fetch(login: params[:user])
  end

  def branch_from_referer
    request.referer.match(/github\.com\/.[^\/]+\/.[^\/]+\/(blob|tree)\/(?<branch>.[^\/]+)/)[:branch]
  rescue NoMethodError
    nil
  end

  def provider_class
    Provider.from_slug params[:provider]
  end

  helper_method :user, :repo

end
