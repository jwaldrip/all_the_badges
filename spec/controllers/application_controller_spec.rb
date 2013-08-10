require 'spec_helper'

describe ApplicationController do

  describe '.rescue_from' do
    let(:error) { StandardError }
    controller do
      def index
        raise sample_error
      end
    end
    before(:each) do
      allow(controller).to receive(:sample_error) {
        stub_const error.name, Class.new(StandardError)
      }
    end

    context 'Github::Error::NotFound' do
      let(:error) { Github::Error::NotFound }
      it 'should redirect to the root with message' do
        get :index
        response.should redirect_to :root
        flash.notice.should eq 'Invalid User or Repo'
      end
    end
  end

end
