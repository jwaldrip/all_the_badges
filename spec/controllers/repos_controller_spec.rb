require 'spec_helper'

describe ReposController, vcr: github_cassette do

  describe 'GET#show' do
    let(:repo){ FactoryGirl.create :repo }
    let(:params){ { user: repo.user_login, repo: repo.name } }

    before(:each) do
      expect(Repo).to receive(:find_or_fetch).with(user: repo.user, name: params[:repo]).and_return(repo)
    end

    it 'should assign @repo a repo' do
      get :show, params
      assigns(:repo).should be_a Repo
      assigns(:repo).user_login.should eq params[:user]
      assigns(:repo).name.should eq params[:repo]
    end
  end

  describe '#user' do
    it 'should find or fetch a user from the params' do
      expect(User).to receive(:find_or_fetch).with login: 'sample-login'
      controller.params = { user: 'sample-login' }
      controller.send :user
    end
  end

end
