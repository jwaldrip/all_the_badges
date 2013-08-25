require 'spec_helper'

describe CachedImage, vcr: github_cassette do
  let(:repo) { FactoryGirl.create(:repo) }
  let(:provider_class) { stub_const 'SampleProvider', Class.new(Provider) }
  let(:provider) { provider_class.new repo: repo }

  context 'class methods' do

    describe '.fetch' do
      it 'should call new and return the body' do
        image_double = double
        expect(image_double).to receive(:body)
        expect(CachedImage).to receive(:new).with(provider) { image_double }
        CachedImage.fetch(provider: provider)
      end
    end

    describe '.new' do
      context 'if a non provider is given as the argument' do
        it 'should raise an error' do
          expect { described_class.new(double) }.to raise_error ArgumentError
        end
      end
    end

  end

  subject(:cached_image) { described_class.new(provider) }

  it { should delegate(:image_url).to(:provider) }
  it { should delegate(:repo).to(:provider) }
  it { should delegate(:display_name).to(:provider).with_prefix }
  it { should delegate(:name).to(:repo).with_prefix }
  it { should delegate(:last_sha).to(:repo).with_prefix }

  describe '#body' do
    context 'given a response' do
      before(:each) do
        response_double = double
        expect(response_double).to receive(:body)
        allow(cached_image).to receive(:response){ response_double }
      end
    end

    context 'given an invalid url' do
      before(:each) do
        allow(cached_image).to receive(:response){ raise URI::InvalidURIError }
        allow(cached_image).to receive(:repo_last_sha){ SecureRandom.hex }
      end
      it 'should try to load a local file' do
        file = File.join File.join 'app', 'assets', 'images', cached_image.image_url
        expect(File).to receive(:read).with(file)
        cached_image.body
      end
    end
  end

  describe '#response' do
    it 'should call http.get with the image_url' do
      expect(cached_image.send(:http)).to receive(:get).with cached_image.image_url
      cached_image.send(:response)
    end
  end

  describe '#http' do
    it 'should be a Faraday connection' do
      cached_image.send(:http).should be_a Faraday::Connection
    end
  end

end
