require 'spec_helper'

describe Repo, vcr: github_cassette do

  let(:user) { User.find_by_login 'jwaldrip' }
  subject(:repo) { user.repos.first }

  context 'matchers' do
    subject { described_class.new }
    it { should belong_to :user }
  end

  describe '.update_from_github' do
    it 'should call github_repos on the user' do
      user.should_receive(:github_repos).and_return([])
      Repo.update_from_github(user)
    end

    it 'should return an AR relation' do
      Repo.update_from_github(user).should be_a ActiveRecord::Relation
    end

    context 'the repo has changed' do
      it 'should save the repo' do
        repo.stub(:changed?).and_return(true)
        remote_repo = double(:repo, id: repo.id, to_hash: {})
        user.stub(:github_repos).and_return([remote_repo])
        user.stub(:local_repos).and_return([repo])
        repo.should_receive(:save)
        Repo.update_from_github(user)
      end
    end

    context 'the repo has no changes' do
      it 'should not the repo' do
        repo.stub(:changed?).and_return(false)
        remote_repo = double(:repo, id: repo.id, to_hash: {})
        user.stub(:github_repos).and_return([remote_repo])
        user.stub(:local_repos).and_return([repo])
        repo.should_not_receive(:save)
        Repo.update_from_github(user)
      end
    end

  end

end
