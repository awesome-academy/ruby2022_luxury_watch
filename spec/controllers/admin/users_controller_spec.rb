require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let!(:user) {FactoryBot.create :user, role: 1}
  let!(:user_1) {FactoryBot.create :user, name: "tuong"}
  let!(:user_2) {FactoryBot.create :user}
  before do
    sign_in user
  end

  describe "GET #index" do
    context "when ransack search name user" do
      it "should search order by name user" do
        get :index, params: {q: {name_cont: "tuong"}}
        expect(assigns(:users)).to eq [user_1]
      end
    end

    context "when ransack not params" do
      it "should return all users" do
        get :index
        expect(assigns(:users)).to eq [user, user_1, user_2]
      end
    end
  end

  describe "DELETE #destroy" do
    context "when find user by id" do
      before do
        @init_count = User.count
        delete :destroy, params:{id: user_1.id}
        @after_delete = User.count
      end

      it "should delete user by id" do
        expect(@init_count - 1).to eq(@after_delete)
      end

      it "redirect admin root path" do
        expect(response).to redirect_to admin_root_path
      end
    end

    context "when not foud user" do
      before do
        delete :destroy, params:{id: -1}
      end

      it "should display flash not found" do
        expect(flash[:danger]).to eq I18n.t("not_found")
      end

      it "redirect to root path" do
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "GET #list_users_delete" do
    let!(:user_3) {FactoryBot.create :user, name: "oanh"}
    let!(:user_4) {FactoryBot.create :user}
    before do
      user_3.delete
      user_4.delete
    end

    context "when ransack search name user" do
      it "should search order by name user" do
        get :list_users_delete, params: {q: {name_cont: "oanh"}}
        expect(assigns(:users)).to eq [user_3]
      end
    end

    context "when ransack not params" do
      it "should return all users" do
        get :list_users_delete
        expect(assigns(:users)).to eq [user_3, user_4]
      end
    end
  end
end
