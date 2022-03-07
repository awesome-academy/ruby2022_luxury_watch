require "rails_helper"
include SessionsHelper
include CartsHelper

RSpec.describe CartsController, type: :controller do
  let!(:user) {FactoryBot.create :user}
  let!(:product_1){FactoryBot.create :product, category_id: category_1.id}
  let!(:product_2){FactoryBot.create :product, name: "casio"}
  let!(:product_3){FactoryBot.create :product, name: "abc"}
  let!(:category_1){FactoryBot.create :category}
  let!(:order_1) {FactoryBot.create :order, user_id: user.id}
  let!(:order_detail_1) {FactoryBot.create :order_detail, order_id: order_1.id}
  let!(:product_size_1){FactoryBot.create :product_size, size: 34}
  let!(:product_color_1){FactoryBot.create :product_color, color: "skysssfksjfk"}
  let!(:product_size_2){FactoryBot.create :product_size, size: 24}
  let!(:product_color_2){FactoryBot.create :product_color, color: "skyss"}
  let!(:product_detail_1){FactoryBot.create :product_detail, product_id: product_1.id,
                                            product_size_id: product_size_1.id,
                                            product_color_id: product_color_1.id, price: 1000}
  let!(:product_detail_2){FactoryBot.create :product_detail, product_id: product_2.id,
        product_size_id: product_size_2.id,
        product_color_id: product_color_2.id, price: 1000}
  describe "GET #index" do
    before do
      sign_in user
      session[:carts] = {}
    end

    context "when current_carts succes" do
      it "show cart" do
        session[:carts] = {product_detail_1.id => 1, product_detail_2.id => 2}
        get :index, params: {locale: I18n.locale}
      end
    end

    context "when current_carts empty" do
      it "show carts" do
        session[:carts] = {}
        get :index, params: {locale: I18n.locale}
      end
    end
  end

  describe "POST #create" do
    before do
      sign_in user
    end

    context "when create success" do
      setup do
        @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
        post :create, params: {id: product_detail_1.id}
      end

      it "should show flash success" do
        expect(flash[:success]).to eq I18n.t("success")
      end
    end

    context "when create fail xhr fail" do
      before do
        post :create, params: {id: -1}
      end
      it "should show flash error" do
        expect(flash[:warning]).to eq I18n.t("not_found")
      end

      it "redirect to root_url" do
        expect(response).to redirect_to root_path
      end
    end

    context "when create fail xhr true" do
      it "should xhr true" do
        post :create, xhr: true, params: {id: -1}
      end
    end
  end

  describe "PUT #update" do
    before do
      sign_in user
      session[:carts] = {}
    end

    context "when update success" do
      before do
        session[:carts] = {product_detail_1.id => "2", product_detail_2.id => "4"}
      end
      it "should update product_detail_id and quantity" do
        put :update, params: {product_detail_id: product_detail_1.id, quantity: 1}, xhr: true, format: :js
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      sign_in user
    end

    context "when delete success" do
      setup do
        @request.env['HTTP_REFERER'] = "http://test.com/sessions/new"
      end
      it "should delete by id" do
        delete :destroy, params: {id: product_detail_1.id}
      end
    end
  end

  describe "#select_cart" do
    setup do
      sign_in user
      @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
    end

    context "when select cart" do
      it "should find product detail" do
        get :select_cart, params: {cart_params: {product_size_id: product_size_1.id,
                                                product_color_id: product_color_1.id,
                                                product_id: product_1.id}}
      end

      it "find product not found" do
        get :select_cart, params: {cart_params: {product_size_id: -1,
                                                product_color_id: -1,
                                                product_id: -1}}
      end
    end
  end
end
