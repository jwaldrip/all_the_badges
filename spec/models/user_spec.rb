require 'spec_helper'

describe User, vcr: github_cassette, clean_db: true do
  subject(:user) { User.find_or_fetch login: 'jwaldrip' }

  context 'matchers' do
    subject { described_class.new }
    it { should have_many(:local_repos).class_name('Repo').with_foreign_key(:user_id) }
    it { should have_many(:repos) }
  end

  describe '.find_or_fetch' do
    before(:each) { allow(User).to receive(:fetch) { FactoryGirl.create :user } }
    context 'given a user is in the database' do
      let(:existing_user) { FactoryGirl.create(:user, login: 'all-the-badges-app') }
      it 'should return a User object' do
        User.find_or_fetch(login: existing_user.login).should be_a User
      end

      it 'should not call .fetch' do
        User.should_not_receive(:fetch)
        User.find_or_fetch(login: existing_user.login)
      end
    end

    context 'given a user is not in the database' do
      it 'should return a User object' do
        User.find_or_fetch(login: 'all-the-badges-app').should be_a User
      end

      it 'should call .fetch' do
        User.should_receive(:fetch)
        User.find_or_fetch(login: 'all-the-badges-app')
      end
    end
  end

  describe '#github_url' do
    it 'should return a github user url' do
      user.github_url.should eq "https://github.com/#{user.login}"
    end
  end

  describe '.fetch' do
    context 'the user exists on github' do
      it 'should not raise an error' do
        expect { User.send(:fetch, login: 'jwaldrip') }.to_not raise_error
      end

      it 'should create a new user' do
        expect { User.send(:fetch, login: 'jwaldrip') }.to change { User.count }.by 1
      end
    end

    context 'the user does not exist on github' do
      it 'should raise an error' do
        expect { User.send(:fetch, login: 'invalid_user') }.to raise_error Github::Error::NotFound
      end
    end
  end
end
