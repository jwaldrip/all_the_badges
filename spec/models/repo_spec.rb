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
    let(:path) { '/' }
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

  describe '#language_is?' do
    context 'if the language matches' do
      it 'should return true' do
        pending
      end
    end

    context 'if the does not match' do
      it 'should return false' do
        pending
      end
    end
  end

  describe '#determine_if_is_package' do
    context 'containing a .gemspec' do
      it 'should set is_package to true' do
        pending
      end
    end

    context 'containing a package.json' do
      it 'should set is_package to true' do
        pending
      end
    end

    context 'containing a setup.py' do
      it 'should set is_package to true' do
        pending
      end
    end

    context 'containing none of the above' do
      it 'should set is_package to false' do
        pending
      end
    end
  end

  describe '#determine_if_contains_bundle' do
    context 'containing a Gemfile' do
      it 'should set contains_bundle to true' do
        pending
      end
    end

    context 'containing a present node_modules directory' do
      it 'should set contains_bundle to true' do
        pending
      end
    end

    context 'containing none of the above' do
      it 'should set contains_bundle to false' do
        pending
      end
    end
  end

  describe '#contains_gemspec?' do
    context 'i not ruby' do
      it 'should be false' do
        pending
      end
    end

    context 'is ruby' do
      context 'has a .gemspec' do
        it 'should be true' do
          pending
        end
      end

      context 'does not have a .gemspec' do
        it 'should be false' do
          pending
        end
      end
    end
  end

  describe '#contains_package_json?' do
    context 'is not javascript' do
      it 'should be false' do
        pending
      end
    end

    context 'is javascript' do
      context 'has a package.json' do
        it 'should be true' do
          pending
        end
      end

      context 'does not have a package.json' do
        it 'should be false' do
          pending
        end
      end
    end
  end

  describe '#contains_setup_script?' do
    context 'is not python' do
      it 'should be false' do
        pending
      end
    end

    context 'is python' do
      context 'has a setup.py' do
        it 'should be true' do
          pending
        end
      end

      context 'does not have a setup.py' do
        it 'should be false' do
          pending
        end
      end
    end
  end

  describe '#contains_gemfile?' do
    context 'is not ruby' do
      it 'should be false' do
        pending
      end
    end

    context 'is ruby' do
      context 'has a Gemfile' do
        it 'should be true' do
          pending
        end
      end

      context 'does not have a Gemfile' do
        it 'should be false' do
          pending
        end
      end
    end
  end

  describe '#contains_node_modules?' do
    context 'is not javascript' do
      it 'should be false' do
        pending
      end
    end

    context 'is javascript' do
      context 'has a present node_modules directory' do
        it 'should be true' do
          pending
        end
      end

      context 'has a empty node_modules directory' do
        it 'should be false' do
          pending
        end
      end

      context 'does not have a node_modules directory' do
        it 'should be false' do
          pending
        end
      end
    end
  end

end
