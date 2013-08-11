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
      let(:existing_repo) { FactoryGirl.create(:repo, user: user, name: 'existing_repo') }
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
        Repo.find_or_fetch(user: 'all-the-badges-app', name: 'all_the_badges').should be_a Repo
      end

      it 'should call .fetch' do
        Repo.should_receive(:fetch)
        Repo.find_or_fetch(user: 'all-the-badges-app', name: 'all_the_badges').should be_a Repo
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
    subject(:repo) { FactoryGirl.create :repo, language: 'Foo Lang' }
    context 'if the language matches' do
      it 'should return true' do
        repo.language_is?(:foo_lang).should be_true
      end
    end

    context 'if the does not match' do
      it 'should return false' do
        repo.language_is?(:bar_lang).should be_false
      end
    end
  end

  describe '#determine_if_is_package' do

    before(:each) do
      allow(repo).to receive(:contains_gemspec?) { false }
      allow(repo).to receive(:contains_package_json?) { false }
      allow(repo).to receive(:contains_setup_script?) { false }
    end

    context 'containing a .gemspec' do
      it 'should set is_package to true' do
        allow(repo).to receive(:contains_gemspec?) { true }
        expect { repo.send(:determine_if_is_package) }.to change {
          repo.is_package
        }.to be_true
      end
    end

    context 'containing a package.json' do
      it 'should set is_package to true' do
        allow(repo).to receive(:contains_package_json?) { true }
        expect { repo.send(:determine_if_is_package) }.to change {
          repo.is_package
        }.to be_true
      end
    end

    context 'containing a setup.py' do
      it 'should set is_package to true' do
        allow(repo).to receive(:contains_setup_script?) { true }
        expect { repo.send(:determine_if_is_package) }.to change {
          repo.is_package
        }.to be_true
      end
    end

    context 'containing none of the above' do
      it 'should set is_package to false' do
        repo.send(:determine_if_is_package)
        repo.is_package.should be_false
      end
    end

  end

  describe '#determine_if_contains_bundle' do

    before(:each) do
      allow(repo).to receive(:contains_gemfile?) { false }
      allow(repo).to receive(:contains_node_modules?) { false }
    end

    context 'containing a Gemfile' do
      it 'should set contains_bundle to true' do
        allow(repo).to receive(:contains_gemfile?) { true }
        expect { repo.send(:determine_if_contains_bundle) }.to change {
          repo.contains_bundle
        }.to be_true
      end
    end

    context 'containing a present node_modules directory' do
      it 'should set contains_bundle to true' do
        allow(repo).to receive(:contains_node_modules?) { true }
        expect { repo.send(:determine_if_contains_bundle) }.to change {
          repo.contains_bundle
        }.to be_true
      end
    end

    context 'containing none of the above' do
      it 'should set contains_bundle to false' do
        repo.send(:determine_if_contains_bundle)
        repo.contains_bundle.should be_false
      end
    end

  end

  context do

    let(:language) { nil }
    let(:file_name) { 'readme.txt' }
    subject(:repo) { Repo.new language: language }
    before(:each) do
      allow(repo).to receive(:contents) {
        [Content.new(repo: repo, name: file_name, content: Base64.encode64('something here'))]
      }
    end

    describe '#contains_gemspec?' do

      context 'is not ruby' do
        it 'should be false' do
          repo.send(:contains_gemspec?).should be_false
        end
      end

      context 'is ruby' do
        let(:language) { 'Ruby' }
        context 'has a .gemspec' do
          let(:file_name) { 'foo.gemspec' }
          it 'should be true' do
            repo.send(:contains_gemspec?).should be_true
          end
        end

        context 'does not have a .gemspec' do
          it 'should be false' do
            repo.send(:contains_gemspec?).should be_false
          end
        end
      end

    end

    describe '#contains_package_json?' do

      context 'is not javascript' do
        it 'should be false' do
          repo.send(:contains_package_json?).should be_false
        end
      end

      context 'is javascript' do
        let(:language) { 'Javascript' }
        context 'has a package.json' do
          let(:file_name) { 'package.json' }
          it 'should be true' do
            repo.send(:contains_package_json?).should be_true
          end
        end

        context 'does not have a package.json' do
          it 'should be false' do
            repo.send(:contains_package_json?).should be_false
          end
        end
      end

    end

    describe '#contains_setup_script?' do

      context 'is not python' do
        it 'should be false' do
          repo.send(:contains_setup_script?).should be_false
        end
      end

      context 'is python' do
        let(:language) { 'Python' }
        context 'has a setup.py' do
          let(:file_name) { 'setup.py' }
          it 'should be true' do
            repo.send(:contains_setup_script?).should be_true
          end
        end

        context 'does not have a setup.py' do
          it 'should be false' do
            repo.send(:contains_setup_script?).should be_false
          end
        end
      end

    end

    describe '#contains_gemfile?' do

      context 'is not ruby' do
        it 'should be false' do
          repo.send(:contains_gemfile?).should be_false
        end
      end

      context 'is ruby' do
        let(:language) { 'Ruby' }
        context 'has a Gemfile' do
          let(:file_name) { 'Gemfile' }
          it 'should be true' do
            repo.send(:contains_gemfile?).should be_true
          end
        end

        context 'does not have a Gemfile' do
          it 'should be false' do
            repo.send(:contains_gemfile?).should be_false
          end
        end

      end

    end

    describe '#contains_node_modules?' do

      context 'is not javascript' do
        it 'should be false' do
          repo.send(:contains_node_modules?).should be_false
        end
      end

      context 'is javascript' do
        let(:language) { 'Javascript' }
        context 'has node modules' do
          let(:file_name) { '/something' }
          it 'should be true' do
            repo.send(:contains_node_modules?).should be_true
          end
        end

        context 'does not have node modules' do
          it 'should be false' do
            allow(repo).to receive(:contents) { [] }
            repo.send(:contains_node_modules?).should be_false
          end
        end

        context 'it cannot find the file' do
          it 'should be false' do
            stub_const 'Github::Error::NotFound', Class.new(StandardError)
            allow(repo).to receive(:contents) { raise Github::Error::NotFound }
            repo.send(:contains_node_modules?).should be_false
          end
        end

      end

    end
  end
end
