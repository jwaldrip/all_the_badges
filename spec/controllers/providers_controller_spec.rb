require 'spec_helper'

describe ProvidersController, vcr: github_cassette do

  before(:each) do
    stub_const 'SampleProvider', Class.new(Provider)
  end
  let(:repo){ FactoryGirl.create :repo }
  let(:user){ repo.user }
  let(:params){ { user: repo.user_login, repo: repo.name } }

  describe 'GET#show' do
    it 'should assign a provider' do
      get :show, provider: 'sample_provider', user: user.login, repo: repo.name
      assigns(:provider).should be_a Provider
    end
  end

  describe '#user' do
    it 'should find or fetch a user from the params' do
      expect(User).to receive(:find_or_fetch).with login: 'sample-login'
      controller.params = { user: 'sample-login' }
      controller.send :user
    end
  end

  describe '#repo' do
    it 'should find or fetch a user from the params' do
      expect(controller).to receive(:user){ user }
      expect(Repo).to receive(:find_or_fetch).with user: user, name: repo.name, branch: nil
      controller.params = { user: user.login, repo: repo.name }
      controller.send :repo
    end
  end

  describe '#branch_from_referer' do
    context 'if github and matches a branch' do
      it 'should return the proper branch' do
        allow(controller.request).to receive(:referer){ 'https://github.com/jwaldrip/all_the_badges/tree/sample_branch' }
        controller.send(:branch_from_referer).should eq 'sample_branch'
      end
    end

    context 'there is not a match' do
      it 'should be nil' do
        controller.send(:branch_from_referer).should be_nil
      end
    end
  end

end
