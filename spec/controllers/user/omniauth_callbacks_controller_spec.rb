require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  describe "Google" do

    context "Success handling" do

      before(:each) do
        request.env["omniauth.auth"] = FactoryBot.create(:auth_hash, :google)
        get :google_oauth2
      end

      let(:user) { User.find_by(email: "testuser@gmail.com") }

      it "should set current_user to proper user" do
        expect(subject.current_user).to eq(user)
      end
    end

    context "Unsuccess handling" do

      before(:each) do
        request.env["omniauth.auth"] = FactoryBot.create(:auth_hash, :google, email: "")
        get :google_oauth2
      end

      it "redirecto signup" do
        expect(subject).to redirect_to new_user_registration_path
      end
    end
  end
end
