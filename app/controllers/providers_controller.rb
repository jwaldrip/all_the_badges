class ProvidersController < ApplicationController

  def show
    @provider = Provider.new repo: repo
  end

  private

  def repo
    @repo ||= Repo.find params[:user], params[:repo], branch: branch_from_referer
  end

  def branch_from_referer
    http_referrer.match(/github\.com\/.[^\/]+\/.[^\/]+\/(blob|tree)\/(?<branch>.[^\/]+)/)[:branch]
  rescue NoMethodError
    nil
  end

  def http_referrer
    request.headers['HTTP_REFERRER'].to_s
  end


end
