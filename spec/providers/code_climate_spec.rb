require 'spec_helper'

describe CodeClimate, vcr: github_cassette do
  include_context 'provider stub'

  describe 'validations' do
    context 'without a #ruby?' do
      it 'should not be valid' do
        allow(provider).to receive(:ruby?){ false }
        provider.should_not be_valid
      end
    end
  end

  describe '#ruby?' do
    it 'should delegate to language is' do
      expect(provider).to receive(:language_is?).with(:ruby)
      provider.send(:ruby?)
    end
  end

end