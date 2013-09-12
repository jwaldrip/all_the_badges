require 'spec_helper'

describe Content, vcr: github_cassette do

  let(:user){ FactoryGirl.build :user, login: 'rails' }
  let(:repo){ FactoryGirl.build :repo, user: user, name: 'rails' }
  let(:data){ Base64.encode64('something') }
  let(:content){ Content.new repo: repo, content: data, path: '/path' }

  describe '.find' do
    let(:response){ nil }
    before(:each) do
      stub_const_mock 'Github'
      allow(Github.repos.contents).to receive(:find){ double(:response, body: response) }
    end

    context 'given it returns an array' do
      let(:response){ [{ foo: :bar, baz: :raz }] }
      it 'should call .new_collection_from_response with the response and repo' do
        fail
        expect(Content).to receive(:new_collection_from_response).with(response, repo)
        Content.find(repo, '/')
      end
    end

    context 'given it returns an hash' do
      let(:response){ { foo: :bar, baz: :raz } }
      it 'should call #new_instance_from_response with the response and repo' do
        expect(Content).to receive(:new_instance_from_response).with(response, repo)
        Content.find(repo, 'Gemfile')
      end
    end

    context 'an error was raise' do
      it 'should be an empty array' do
        stub_const 'Github::Error::NotFound', Class.new(StandardError)
        allow(Github.repos.contents).to receive(:find){ raise Github::Error::NotFound }
        Content.find(repo, 'Gemfile').should_not be_present
      end
    end
  end

  describe '.new_collection_from_response' do
    let(:response){ [{ foo: :bar, baz: :raz }, { fast: :car, slow: :tar }] }
    it 'should call new on each item in the response with the repo' do
      response.each do |file|
        expect(Content).to receive(:new_instance_from_response).with(file, repo)
      end
      Content.send :new_collection_from_response, response, repo
    end
  end

  describe '.new_instance_from_response' do
    let(:response){ { foo: :bar, baz: :raz } }
    it 'should call new with the attributes combined with the repo' do
      expect(Content).to receive(:new).with response.merge repo: repo
      Content.send(:new_instance_from_response, response, repo)
    end
  end

  describe '#read' do

    it 'should decode the content' do
      content.read.should eq 'something'
    end

    context 'content is not loaded' do
      let(:data){ nil }
      it 'should call reload' do
        expect(content).to receive(:reload){ content.content = Base64.encode64('something') }
        content.read
      end

      it 'should not raise an error' do
        allow(content).to receive(:reload){ content.content = Base64.encode64('something') }
        expect { content.read }.to_not raise_error
      end

      context 'content remains nil' do
        it 'should not raise an error' do
          allow(content).to receive(:reload)
          expect { content.read }.to_not raise_error
        end
      end
    end

  end

  describe '#reload' do
    it 'should call replace with a new instance from find' do
      new_instance_double = double(:new_instance)
      expect(Content).to receive(:find).with(content.repo, content.path){ new_instance_double }
      expect(content).to receive(:replace).with new_instance_double
      content.reload
    end
  end

  describe '#replace' do
    let(:new_content){ Content.new repo: repo.dup, content: Base64.encode64('something else'), path: '/new_path' }
    it 'should replace its instance variables' do
      allow(content).to receive(:get_values){
        content.instance_variables.reduce({}) do |hash, var|
          hash.merge var => content.instance_variable_get(var)
        end
      }
      original_values = content.get_values
      expect { content.replace new_content }.to change { content.get_values }
      content.get_values.should_not include original_values
    end
  end

end