require 'spec_helper'

describe Repo, vcr: github_cassette, clean_db: true do

  let(:user) { User.find_or_fetch login: 'jwaldrip' }
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

  describe '.find_or_fetch' do
    before(:each) { allow(Repo).to receive(:fetch) { FactoryGirl.create :repo } }
    context 'given a repo is in the database' do
      let(:existing_repo) { FactoryGirl.create(:repo, user: user, name: SecureRandom.hex) }
      it 'should return a User object' do
        Repo.find_or_fetch(user: user, name: existing_repo.name).should be_a Repo
      end

      it 'should not call .fetch' do
        Repo.should_not_receive(:fetch)
        Repo.find_or_fetch(user: user, name: existing_repo.name)
      end
    end

    context 'given a repo is not in the database' do
      it 'should return a User object' do
        Repo.find_or_fetch(user: SecureRandom.hex, name: SecureRandom.hex).should be_a Repo
      end

      it 'should call .fetch' do
        Repo.should_receive(:fetch)
        Repo.find_or_fetch(user: SecureRandom.hex, name: SecureRandom.hex).should be_a Repo
      end
    end
  end

  describe '.fetch' do
    context 'the repo exists on github' do
      it 'should not raise an error' do
        expect { Repo.send(:fetch, user: user, name: 'all_the_badges') }.to_not raise_error
      end

      it 'should create a new user' do
        expect { Repo.send(:fetch, user: user, name: 'all_the_badges') }.to change { Repo.count }.by 1
      end
    end

    context 'the repo does not exist on github' do
      it 'should raise an error' do
        expect { Repo.send(:fetch, user: double(:user, login: 'invalid_user'), name: 'invalid_repo') }.to raise_error Github::Error::NotFound
      end
    end
  end

  describe '#branch' do
    context 'if a branch is set' do
      it 'should use the set branch' do
        repo.branch = 'hello'
        repo.branch.should eq 'hello'
      end
    end

    context 'if a branch is not set' do
      it 'should call the default branch' do
        expect(repo).to receive :default_branch
        repo.branch
      end
    end
  end

  describe '#contents' do
    let(:path){ '/' }
    it 'should change the value of the memoized hash' do
      expect { repo.contents path }.to change {
        repo.instance_variable_get(:@contents)
      }.to have_key path
    end

    it 'should call Content.find with the repo and path' do
      expect(Content).to receive(:find).with(repo, path)
      repo.contents path
    end
  end

  describe '#providers' do
    it 'should call Provider#for_repo with the repo' do
      expect(Provider).to receive(:for_repo).with repo
      repo.providers
    end

    it 'should be memoized' do
      expect(Provider).to receive(:for_repo) { 'something' }.once
      expect { repo.providers }.to change { repo.instance_variable_get :@providers }
      repo.providers
    end
  end

end
