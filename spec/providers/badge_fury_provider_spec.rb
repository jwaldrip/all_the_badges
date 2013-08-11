require 'spec_helper'

describe BadgeFuryProvider, vcr: github_cassette do
  include_context 'provider stub'

  describe '#package_name' do
    it 'should call #repo_name' do
      expect(provider).to receive :repo_name
      provider.send(:package_name)
    end
  end

  describe '#project_type' do
    it 'should call the method for each of the required languages' do
      [:rb, :js, :py].each do |lang|
        expect(provider).to receive("#{lang}?"){ false }
      end
      provider.send(:project_type)
    end

    it 'should return a proper value if one of the languages is found' do
      expect(provider).to receive(:rb?){ true }
      provider.send(:project_type).should eq :rb
    end
  end

  describe '#rb?' do
    context 'when the language is ruby' do
      let(:attrs){ { language: 'Ruby' } }
      context 'and is a package' do
        let(:methods){ { is_package?: true } }
        it 'should be true' do
          provider.send(:rb?).should be_true
        end
      end

      context 'and is not a package' do
        it 'should be false' do
          provider.send(:rb?).should be_false
        end
      end

    end

    context 'when the language is not ruby' do
      it 'should be false' do
        provider.send(:rb?).should be_false
      end
    end
  end

  describe '#js?' do
    context 'when the language is javascript' do
      let(:attrs){ { language: 'Javascript' } }
      context 'and is a package' do
        let(:methods){ { is_package?: true } }
        it 'should be true' do
          provider.send(:js?).should be_true
        end
      end

      context 'and is not a package' do
        it 'should be false' do
          provider.send(:js?).should be_false
        end
      end

    end

    context 'when the language is not javascript' do
      it 'should be false' do
        provider.send(:js?).should be_false
      end
    end
  end

  describe '#py?' do
    context 'when the language is python' do
      let(:attrs){ { language: 'Python' } }
      context 'and is a package' do
        let(:methods){ { is_package?: true } }
        it 'should be true' do
          provider.send(:py?).should be_true
        end
      end

      context 'and is not a package' do
        it 'should be false' do
          provider.send(:py?).should be_false
        end
      end

    end

    context 'when the language is not python' do
      it 'should be false' do
        provider.send(:py?).should be_false
      end
    end
  end

end