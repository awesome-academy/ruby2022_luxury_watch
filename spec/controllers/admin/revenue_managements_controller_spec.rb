require "rails_helper"

RSpec.describe Admin::RevenueManagementsController, type: :controller do
  let!(:user) {FactoryBot.create :user, role: 1}
  before do
    sign_in user
  end

  describe "GET #index" do
    it "render index" do
      get :index, params: {locale: I18n.locale}

      expect(response).to have_http_status(:success)
    end
  end
end
