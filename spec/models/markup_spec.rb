require 'spec_helper'

describe Markup, vcr: github_cassette do

  context 'class_methods' do

    subject(:markup) { stub_const 'SampleMarkup', Class.new(Markup) }

    describe '.list' do
      let(:markups) do
        3.times.each_with_index.map do |i|
          name  = "SampleMatcher#{i+1}"
          klass = Class.new(Markup)
          stub_const name, klass
          Rails.root.join('app', 'markups', name.underscore + '.rb').to_s
        end
      end

      before(:each) do
        allow(Dir).to receive(:glob).and_return(markups)
      end

      it 'should return providers' do
        Markup.list.size.should eq markups.size
      end

      it 'should not raise an error' do
        expect { Markup.list }.to_not raise_error
      end

      it 'should not return classes that are not descendants of Provider' do
        markups << Rails.root.join('app', 'markups', 'object.rb').to_s
        Markup.list.should_not include Object
      end
    end

    describe '.supported_by_language' do
      before(:each) { allow(Markup).to receive(:list) { [markup, Class.new(Markup)] } }
      context 'given the Markup supports all languages' do
        before(:each) do
          markup.send :languages, :all
        end

        context 'given any language' do
          it 'should return the markup' do
            [:foo, :bar, :baz].each do |lang|
              Markup.supported_by_language(lang).should include markup
            end
          end
        end

      end

      context 'given the Markup supports a specific language' do
        before(:each) do
          markup.send :languages, :supported_lang
        end

        context 'given a supported language' do
          it 'should return the markup' do
            Markup.supported_by_language(:supported_lang).should include markup
          end
        end

        context 'given an un-supported language' do
          it 'should not return the markup' do
            Markup.supported_by_language(:unsupported_lang).should_not include markup
          end
        end
      end
    end

    describe '.for_repo' do
      let(:repo) do
        double.tap do |mock|
          allow(mock).to receive(:language) { :something }
          allow(mock).to receive(:providers) { [provider] }
        end
      end
      let(:provider) {
        klass = stub_const 'SampleProvider', Class.new(Provider)
        klass.new repo: repo
      }
      let(:markups) do
        5.times.each_with_index.map do |i|
          name  = "SampleMatcher#{i+1}"
          klass = Class.new(Markup)
          klass.send(:template, "template for #{name}")
          stub_const name, klass
        end
      end
      before(:each) do
        allow(Markup).to receive(:supported_by_language) { markups }
      end

      it 'should return a key for each markup' do
        result = Markup.for_repo(repo)
        markups.each do |markup|
          result.should include markup.display_name => "template for #{markup.name}"
        end
      end
    end

    describe '.for_provider' do
      it 'should call new with a provider and host' do
        provider_mock = double
        host_mock     = double
        markup_double = double.tap { |mock| expect(mock).to receive(:output) }
        expect(markup).
          to receive(:new).
               with(provider: provider_mock, host: host_mock).
               and_return markup_double
        markup.for_provider(provider_mock, host: host_mock)
      end
    end

    describe '.display_name' do
      context 'given display name is set' do
        let(:display_name) { 'Foo Markup' }
        before(:each) do
          markup.send :set_display_name, display_name
        end
        it 'should return the set display name' do
          markup.display_name.should eq display_name
        end
      end

      context 'given display name is not set' do
        it 'should return the class name without Markup' do
          markup.display_name.should eq 'Sample'
        end
      end
    end

    describe '_languages' do
      it 'should be an array' do
        markup._languages.should be_a Array
      end
    end

    describe '_languages=' do
      let(:languages) { [:foo] }
      it 'should change the value of @display_name' do
        expect { markup.send :_languages=, languages }.
          to change { markup.instance_variable_get :@_languages }.
               to languages
      end
    end

    describe '.set_display_name' do
      let(:display_name) { 'Foo Markup' }
      it 'should change the value of @display_name' do
        expect { markup.send :set_display_name, display_name }.
          to change { markup.instance_variable_get :@display_name }.
               to display_name
      end
    end

    describe '.languages' do
      it 'should append a new language' do
        expect { markup.send :languages, :foo }.
          to change { markup._languages }.
               to include Language.new(:foo)
      end
    end

    describe '.template' do
      let(:content) { 'content' }
      it 'should call SymbolConverter.replace! with the content' do
        expect(SymbolConverter).to receive(:replace!).with('content')
        markup.send(:template, content)
      end

      it 'should define an output method' do
        expect(markup).to receive(:method_added).with(:output)
        markup.send(:template, content)
      end
    end


    describe '.method_that_does_not_exist' do
      it 'should raise a no method error' do
        expect { markup.method_that_does_not_exist }.to raise_error NoMethodError
      end
    end

  end

  let(:klass) { stub_const 'SampleMarkup', Class.new(Markup) }
  let(:repo) { double.as_null_object }
  subject(:instance) { klass.new provider: Provider.new(repo: repo), host: 'http://localhost:3000' }
  it { should delegate(:alt).to(:provider).with_prefix }
  it { should delegate(:display_name).to(:provider).with_prefix }

  describe '#port' do
    it 'should parse the port from the url' do
      instance.port.should eq 3000
    end
  end

  describe '#image_url' do
    it 'should call provider_url with the proper arguments' do
      provider = instance.provider
      expect(instance).
        to receive(:provider_url).
             with provider: provider.slug,
                  repo:     provider.repo_name,
                  user:     provider.user_login,
                  format:   :png,
                  host:     instance.host,
                  port:     instance.port

      instance.image_url
    end
  end

  describe '#link_url' do
    it 'should call provider_url with the proper arguments' do
      provider = instance.provider
      expect(instance).
        to receive(:provider_url).
             with provider: provider.slug,
                  repo:     provider.repo_name,
                  user:     provider.user_login,
                  host:     instance.host,
                  port:     instance.port

      instance.link_url
    end
  end

end