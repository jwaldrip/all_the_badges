require 'spec_helper'

describe Provider, vcr: github_cassette do
  let(:user){ User.find_or_fetch(login: 'jwaldrip') }
  let(:repo){ Repo.find_or_fetch(user: user, name: 'all_the_badges') }
  subject(:provider) { Provider.new repo: repo }

  it { should delegate(:branch).to(:repo) }
  it { should delegate(:name).to(:repo).with_prefix }
  it { should delegate(:login).to(:user).with_prefix }

  describe 'validations' do
    context 'without a image_url and link_url' do
      it 'should not be valid' do
        provider.should_not be_valid
      end
    end
  end

end