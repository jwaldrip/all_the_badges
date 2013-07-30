class ProvidersController < ApplicationController
  include ActionView::Helpers::AssetUrlHelper

  def show
    @provider = provider.new repo: repo
    respond_to do |format|
      format.png { render_image }
      format.any { redirect_to_provider }
    end
  end

  private

  def render_image
    expires_in 0.seconds, public: false, must_revalidate: true
    response.cache_control.replace(max_age: 10.seconds, public: false, must_revalidate: true)
    redirect_to image_path @provider.image_url
  end

  def redirect_to_provider
    redirect_to @provider.link_url
  end

  def repo
    @repo ||= Repo.find params[:user], params[:repo], branch: branch_from_referer
  end

  def branch_from_referer
    request.referer.match(/github\.com\/.[^\/]+\/.[^\/]+\/(blob|tree)\/(?<branch>.[^\/]+)/)[:branch]
  rescue NoMethodError
    nil
  end

  def provider
    params[:provider].camelize.constantize
  end

end
