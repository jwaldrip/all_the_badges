require 'spec_helper'

describe Provider, vcr: github_cassette do
  let(:user) { User.find_or_fetch(login: 'jwaldrip') }
  let(:repo) { Repo.find_or_fetch(user: user, name: 'all_the_badges') }
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

  describe '.image_url' do
    it 'should call convert_symbols' do
      expect(Provider).to receive(:convert_symbols!).with(':value')
      Provider.image_url ':value'
    end

    it 'should define an image_url instance method' do
      expect(Provider).to receive(:method_added).with(:raw_image_url)
      Provider.image_url ':value'
    end

    it 'should define a method that returns the proper result' do
      Provider.image_url 'example/:value'
      allow(provider).to receive(:value) { 'foo' }
      allow(provider).to receive(:created?) { true }
      provider.image_url.should eq 'example/foo'
    end
  end

  describe '.link_url' do
    it 'should call convert_symbols' do
      expect(Provider).to receive(:convert_symbols!).with(':value')
      Provider.link_url ':value'
    end

    it 'should define an image_url instance method' do
      expect(Provider).to receive(:method_added).with(:raw_link_url)
      Provider.link_url ':value'
    end
  end

  describe '.creatable!' do
    it 'should call convert_symbols with the values for link_url and image_url' do
      expect(Provider).to receive(:convert_symbols!).with(':foo_value')
      expect(Provider).to receive(:convert_symbols!).with(':bar_value')
      Provider.creatable! link_url: ':foo_value', image_url: ':bar_value'
    end

    it 'should define the proper methods' do
      expect(Provider).to receive(:method_added).with(:create_link_url)
      expect(Provider).to receive(:method_added).with(:create_image_url)
      Provider.creatable! link_url: ':foo_value', image_url: ':bar_value'
    end
  end

  describe '.from_slug' do
    context 'the constant exists' do
      context 'the provider is valid' do
        before(:each){ stub_const 'FooProvider', Class.new(Provider) }
        it 'should not raise an error' do
          expect { Provider.from_slug('foo_provider') }.to_not raise_error
        end

        it 'should return the provider class' do
          Provider.from_slug('foo_provider').should eq FooProvider
        end
      end
    end

    context 'the constant is not a descendant of Provider' do
      it 'should raise an error' do
        expect {
          Provider.from_slug 'string'
        }.to raise_error Provider::InvalidProvider,
                         'String is not a valid Provider'
      end
    end

    context 'the constant does not exist' do
      it 'should raise an error' do
        expect {
          Provider.from_slug 'this_is_not_valid'
        }.to raise_error Provider::InvalidProvider,
                         'Could not locate a matching constant for this_is_not_valid'
      end
    end
  end

  describe '.for_repo' do
    pending
  end

  describe '.list' do

  end

  describe '.display_name' do
    it 'should set the method #display_name' do
      expect(Provider).to receive(:method_added).with(:display_name)
      Provider.display_name nil
    end
  end

  describe '#display_name' do
    context 'when nil or not set' do
      it 'should be the titleized name of the class' do
        Provider.display_name nil
        allow(Provider).to receive(:name) { 'FooBarBaz' }
        provider.display_name.should eq 'Foo Bar Baz'
      end
    end

    context 'when set' do
      it 'should be the proper display name' do
        Provider.display_name 'Something'
        provider.display_name.should eq 'Something'
      end
    end
  end

  describe '#image_url' do
    before(:each) { Provider.image_url 'example/:value' }
    context 'when the provider exists' do
      it 'should return the link_url' do
        allow(provider).to receive(:value) { 'foo' }
        allow(provider).to receive(:created?) { true }
        provider.image_url.should eq 'example/foo'
      end
    end

    context 'when the provider does not exist' do
      it 'should call create_link_url' do
        allow(provider).to receive(:value) { 'foo' }
        allow(provider).to receive(:created?) { false }
        expect(provider).to receive(:create_image_url)
        provider.image_url
      end
    end
  end

  describe '#link_url' do
    before(:each) { Provider.link_url 'example/:value' }
    context 'when the provider exists' do
      it 'should return the link_url' do
        allow(provider).to receive(:value) { 'bar' }
        allow(provider).to receive(:created?) { true }
        provider.link_url.should eq 'example/bar'
      end
    end

    context 'when the provider does not exist' do
      it 'should call create_link_url' do
        allow(provider).to receive(:value) { 'bar' }
        allow(provider).to receive(:created?) { false }
        expect(provider).to receive(:create_link_url)
        provider.link_url
      end
    end
  end

  describe '#create_image_url' do
    before(:each) do
      Provider.creatable! link_url: 'create/:foo_value', image_url: 'create/:bar_value'
      allow(provider).to receive(:foo_value) { 'foo' }
      allow(provider).to receive(:bar_value) { 'bar' }
    end
    it 'should return the create_image_url' do
      provider.create_image_url.should eq 'create/bar'
    end
  end

  describe '#create_link_url' do
    before(:each) do
      Provider.creatable! link_url: 'create/:foo_value', image_url: 'create/:bar_value'
      allow(provider).to receive(:foo_value) { 'foo' }
      allow(provider).to receive(:bar_value) { 'bar' }
    end
    it 'should return the create_link_url' do
      provider.create_link_url.should eq 'create/foo'
    end
  end

  describe '#repo' do
    it 'should not raise an error' do
      expect { provider.repo }.to_not raise_error
    end
  end

  describe '#cache_key' do
    it 'should include the proper values' do
      provider.cache_key.split('/').should include provider.user_login, provider.repo_name, provider.branch
    end
  end

end