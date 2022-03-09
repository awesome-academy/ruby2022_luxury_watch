require "rails_helper"
include SessionsHelper
include CartsHelper

RSpec.describe OrdersController, type: :controller do

  let!(:user) {FactoryBot.create :user}
  let!(:category_1){FactoryBot.create :category}
  let!(:product_1){FactoryBot.create :product, category_id: category_1.id}
  let!(:product_2){FactoryBot.create :product, name: "casio"}
  let!(:product_3){FactoryBot.create :product, name: "abc"}
  let!(:order_1){FactoryBot.create :order,
                                    user_name_at_order: user.name,
                                    status: Settings.order_shipping,
                                    user_id: user.id}
  let!(:order_2){FactoryBot.create :order,
                                    user_name_at_order: user.name,
                                    status: Settings.order_delivered,
                                    user_id: user.id}

  let!(:product_size_1){FactoryBot.create :product_size, size: 34}
  let!(:product_color_1){FactoryBot.create :product_color}
  let!(:product_size_2){FactoryBot.create :product_size, size: 24}
  let!(:product_color_2){FactoryBot.create :product_color, color: "skyssss"}
  let!(:product_detail_1){FactoryBot.create :product_detail, product_id: product_1.id,
                                            product_size_id: product_size_1.id,
                                            product_color_id: product_color_1.id, price: 1000}
  let!(:product_detail_2){FactoryBot.create :product_detail, product_id: product_2.id,
                                            product_size_id: product_size_2.id,
                                            product_color_id: product_color_2.id, price: 1000}
  let!(:order_detail_1) {FactoryBot.create :order_detail,
                                            order_id: order_1.id,
                                            product_detail_id: product_detail_1.id}
  let!(:order_detail_2) {FactoryBot.create :order_detail,
                                            order_id: order_2.id,
                                            product_detail_id: product_detail_2.id}
  describe "GET #index" do
    describe "when logged in" do
      before do
        sign_in user
      end
      context "when has not params" do
        it "should return all orders" do
          get :index
          expect(assigns(:orders)).to eq [order_1, order_2]
        end
      end

      context "when ransack status" do
        it "should search by status order" do
          get :index, params: {q: {status_cont: "2"}}
          expect(assigns(:orders)).to eq [order_1]
        end
      end

      context "when ransack search name product" do
        it "should search order by name product" do
          get :index, params: {q: {name_cont: "casio"}}
          expect(assigns(:orders)).to eq [order_2]
        end
      end
    end
  end

  describe "POST #create" do
    let!(:init_order_count){Order.count}

    before do
      sign_in user
      session[:carts] = {}
    end

    context "when current_carts succes" do
      before do
        session[:carts] = {product_detail_1.id => 1, product_detail_2.id => 2}
        post :create, params: {locale: I18n.locale, order: order_1}
        @final_count = Order.count
      end

      it "quantity plus" do
        expect(@final_count - init_order_count).to eq(1)
      end

      it "flash display success" do
        expect(flash[:success]).to eq I18n.t("success")
      end

      it "redirect to root_url" do
        expect(response).to redirect_to root_url
      end
    end

    context "when current_carts fail" do
      before do
        session[:carts] = {-2 => 1, -1 => 2}
        post :create, params: {locale: I18n.locale, order: order_1}
        @final_count = Order.count
      end

      it "order not change" do
        expect(@final_count - init_order_count).to eq(0)
      end

      it "flash display error" do
        expect(flash.now[:danger]).to eq I18n.t("error")
      end

      it "redirect to root_url" do
        expect(response).to redirect_to root_url
      end
    end
  end

  describe "PUT #update" do
    let!(:user) {FactoryBot.create :user}
    let!(:product_1){FactoryBot.create :product, category_id: category_1.id}
    let!(:product_2){FactoryBot.create :product, name: "casio"}
    let!(:product_3){FactoryBot.create :product, name: "abc"}
    let!(:category_1){FactoryBot.create :category}
    let!(:order_1) {FactoryBot.create :order, user_id: user.id}
    let!(:order_detail_1) {FactoryBot.create :order_detail, order_id: order_1.id}
    let!(:product_size_1){FactoryBot.create :product_size, size: 34}
    let!(:product_color_1){FactoryBot.create :product_color}
    let!(:product_size_2){FactoryBot.create :product_size, size: 24}
    let!(:product_color_2){FactoryBot.create :product_color, color: "skyss"}
    let!(:product_detail_1){FactoryBot.create :product_detail, product_id: product_1.id,
                                              product_size_id: product_size_1.id,
                                              product_color_id: product_color_1.id, price: 1000}
    let!(:product_detail_2){FactoryBot.create :product_detail, product_id: product_2.id,
          product_size_id: product_size_2.id,
          product_color_id: product_color_2.id, price: 1000}

    setup do
      sign_in order_1.user
      @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
    end

    context "when order status wait" do
      before do
        order_1.rejected!
        put :update, params: {id: order_1.id}
      end
      it "check status update" do
        expect(order_1.status).to eq "rejected"
      end
    end

    context "when status not wait" do
      before do
        order_1.wait!
        put :update, params: {id: order_1.id}
      end

      it "check status update" do
        expect(order_1.status).to eq "wait"
      end
    end
  end
end
