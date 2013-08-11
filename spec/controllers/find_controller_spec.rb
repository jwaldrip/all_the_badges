require 'spec_helper'

describe FindController do

  describe 'POST#create' do
    context 'given a user and repo' do
      let(:request!){ post :create, query: 'user/repo' }
      it 'should call #redirect_to_repo' do
        expect(controller).to receive(:redirect_to_repo).and_call_original
        request!
      end

      it 'should redirect to the repo' do
        request!
        response.should redirect_to repo_path(user: 'user', repo: 'repo')
      end
    end

    context 'given a user' do
      let(:request!){ post :create, query: 'user' }
      it 'should call #redirect_to_user' do
        expect(controller).to receive(:redirect_to_user).and_call_original
        request!
      end

      it 'should redirect to the repo' do
        request!
        response.should redirect_to user_path(user: 'user')
      end
    end

    context 'given an invalid query' do
      let(:request!){ post :create, query: '' }
      it 'should redirect back with a notice' do
        request.env["HTTP_REFERER"] = 'http://test.host/'
        request!
        response.should redirect_to :back
        flash.notice.should eq 'Invalid Query'
      end
    end
  end

end
