require 'spec_helper'

describe Provider, vcr: github_cassette do
  let(:user) { User.find_or_fetch(login: 'jwaldrip') }
  let(:repo) { Repo.find_or_fetch(user: user, name: 'all_the_badges') }
  subject(:provider) { Provider.new repo: repo }

  # Resets the class
  before(:each) do
    Provider.send :display_name, nil
    Provider.send :image_url, nil
    Provider.send :link_url, nil
    Provider.send :creatable!
    Provider.send :order, 99
  end

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
      expect(SymbolConverter).to receive(:replace!).with(':value')
      Provider.send :image_url, ':value'
    end

    it 'should define an image_url instance method' do
      expect(Provider).to receive(:method_added).with(:raw_image_url)
      Provider.send :image_url, ':value'
    end

    it 'should define a method that returns the proper result' do
      Provider.send :image_url, 'example/:value'
      allow(provider).to receive(:value) { 'foo' }
      allow(provider).to receive(:created?) { true }
      provider.image_url.should eq 'example/foo'
    end
  end

  describe '.link_url' do
    it 'should call convert_symbols' do
      expect(SymbolConverter).to receive(:replace!).with(':value')
      Provider.send :link_url, ':value'
    end

    it 'should define an image_url instance method' do
      expect(Provider).to receive(:method_added).with(:raw_link_url)
      Provider.send :link_url, ':value'
    end
  end

  describe '.creatable!' do
    it 'should call convert_symbols with the values for link_url and image_url' do
      expect(SymbolConverter).to receive(:replace!).with(':foo_value')
      expect(SymbolConverter).to receive(:replace!).with(':bar_value')
      Provider.send :creatable!, link_url: ':foo_value', image_url: ':bar_value'
    end

    it 'should define the proper methods' do
      expect(Provider).to receive(:method_added).with(:create_link_url)
      expect(Provider).to receive(:method_added).with(:create_image_url)
      Provider.send :creatable!, link_url: ':foo_value', image_url: ':bar_value'
    end
  end

  describe '.from_slug' do
    context 'the constant exists' do
      context 'the provider is valid' do
        before(:each){ stub_const 'FooProvider', Class.new(Provider) }
        it 'should not raise an error' do
          expect { Provider.from_slug('foo') }.to_not raise_error
        end

        it 'should return the provider class' do
          Provider.from_slug('foo').should eq FooProvider
        end
      end
    end

    context 'the constant is not a descendant of Provider' do
      before(:each){ stub_const 'InvalidProvider', Class.new }
      it 'should raise an error' do
        expect {
          Provider.from_slug 'invalid'
        }.to raise_error Provider::InvalidProvider,
                         'InvalidProvider is not a valid Provider'
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
    let(:list_double) do
      provider_mock = stub_const('FooProvider', Class.new(Provider))
      [provider_mock]
    end
    before(:each){ allow(Provider).to receive(:list).and_return(list_double) }
    it 'should map over list' do
      expect(list_double).to receive(:map).and_call_original
      expect(Provider).to receive(:list).and_return(list_double)
      Provider.for_repo repo
    end

    it 'should select #valid? on each provider' do
      mapped_double = [provider]
      allow(Provider.list).to receive(:map).and_return mapped_double
      expect(mapped_double).to receive(:select).and_call_original
      mapped_double.each do |p|
        expect(p).to receive(:valid?)
      end
      Provider.for_repo repo
    end

    it 'should sort by #order on each provider' do
      mapped_double = [provider]
      allow(Provider.list).to receive(:map).and_return mapped_double
      allow(mapped_double).to receive(:select).and_return mapped_double
      expect(mapped_double).to receive(:sort_by).and_call_original
      mapped_double.each do |p|
        expect(p).to receive(:order)
      end
      Provider.for_repo repo
    end

  end

  describe '.list' do
    let(:providers) do
      3.times.each_with_index.map do |i|
        name = "SampleProvider#{i+1}"
        klass = Class.new(Provider)
        stub_const name, klass
        Rails.root.join('app', 'providers', name.underscore + '.rb').to_s
      end
    end

    before(:each) do
      allow(Dir).to receive(:glob).and_return(providers)
    end

    it 'should return providers' do
      Provider.list.size.should eq providers.size
    end

    it 'should not raise an error' do
      expect { Provider.list }.to_not raise_error
    end

    it 'should not return classes that are not descendants of Provider' do
      providers << Rails.root.join('app', 'providers', 'object.rb').to_s
      Provider.list.should_not include Object
    end
  end

  describe '.display_name' do
    it 'should set the method #display_name' do
      expect(Provider).to receive(:method_added).with(:display_name)
      Provider.send :display_name, nil
    end
  end

  describe '#display_name' do
    context 'when nil or not set' do
      it 'should be the titleized name of the class' do
        Provider.send :display_name, nil
        allow(Provider).to receive(:name) { 'FooBarBaz' }
        provider.display_name.should eq 'Foo Bar Baz'
      end
    end

    context 'when set' do
      it 'should be the proper display name' do
        Provider.send :display_name, 'Something'
        provider.display_name.should eq 'Something'
      end
    end
  end

  describe '#slug' do
    it 'should be the class constant underscored' do
      stub_const 'SampleProvider', Class.new(Provider)
      SampleProvider.new.slug.should eq 'sample'
    end
  end

  describe '#image_url' do
    before(:each) { Provider.send :image_url, 'example/:value' }
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
    before(:each) { Provider.send :link_url,  'example/:value' }
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
      Provider.send :creatable!, link_url: 'create/:foo_value', image_url: 'create/:bar_value'
      allow(provider).to receive(:foo_value) { 'foo' }
      allow(provider).to receive(:bar_value) { 'bar' }
    end
    it 'should return the create_image_url' do
      provider.create_image_url.should eq 'create/bar'
    end
  end

  describe '#create_link_url' do
    before(:each) do
      Provider.send :creatable!, link_url: 'create/:foo_value', image_url: 'create/:bar_value'
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