require 'spec_helper'

describe Gemnasium, vcr: github_cassette do
  include_context 'provider stub'

  describe 'validations' do
    context 'without a #package_supported? and #language_supported?' do
      it 'should not be valid' do
        allow(provider).to receive(:package_supported?){ false }
        allow(provider).to receive(:language_supported?){ false }
        provider.should_not be_valid
      end
    end
  end

  describe '#language_supported?' do
    it 'should call language is with ruby and javascript' do
      [:ruby, :javascript].each do |lang|
        expect(provider).to receive(:language_is?).with(lang).and_return(false)
      end
      provider.send(:language_supported?)
    end
  end

  describe '#package_supported?' do
    it 'should call each of the required methods' do
      [:contains_bundle?, :is_package?].each do |method|
        expect(provider).to receive(method).and_return(false)
      end
      provider.send(:package_supported?)
    end
  end


end