require 'spec_helper'

describe UsersController do

  describe 'GET#show' do
    let(:params){ { user: 'sample-login' } }
    before(:each) do
      expect(User).to receive(:find_or_fetch).with(login: params[:user]){ FactoryGirl.build :user, login: params[:user] }
    end

    it 'should assign @user a user' do
      get :show, params
      assigns(:user).login.should eq params[:user]
    end
  end

end
