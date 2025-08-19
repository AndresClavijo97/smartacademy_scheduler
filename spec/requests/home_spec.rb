require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    context 'when user is authenticated' do
      let(:user) { create(:user) }

      it 'returns successful response' do
        post user_session_path, params: { user: { email: user.email, password: 'password123' } }
        get root_path
        expect(response).to have_http_status(:success)
      end

      it 'shows content for authenticated users' do
        post user_session_path, params: { user: { email: user.email, password: 'password123' } }
        get root_path
        expect(response.body).to include('html')
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to login page' do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
