class ProvidersController < ApplicationController

  def show
    @provider = provider.new repo: repo
    respond_to do |format|
      format.png { redirect_to @provider.image_url }
      format.any { render }
    end
  end

  private

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
