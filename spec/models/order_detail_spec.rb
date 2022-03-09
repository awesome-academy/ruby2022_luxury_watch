require 'rails_helper'

RSpec.describe OrderDetail, type: :model do
  describe "Scopes" do
    let!(:user){FactoryBot.create :user, name: "tuongabc"}
    let!(:category_1){FactoryBot.create :category}
    let!(:product_1){FactoryBot.create :product, category_id: category_1.id}
    let!(:product_2){FactoryBot.create :product, name: "casio"}
    let!(:product_3){FactoryBot.create :product, name: "abc"}
    let!(:product_4){FactoryBot.create :product, name: "abcsssss"}
    let!(:order_1){FactoryBot.create :order,
                                     user_name_at_order: user.name,
                                     status: Settings.order_shipping,
                                     user_id: user.id}
    let!(:order_2){FactoryBot.create :order,
                                     user_name_at_order: user.name,
                                     status: Settings.order_delivered,
                                     user_id: user.id}
    let!(:order_3){FactoryBot.create :order,
                                      user_name_at_order: user.name,
                                      status: Settings.order_wait,
                                      user_id: user.id}
    let!(:order_4){FactoryBot.create :order,
                                      user_name_at_order: user.name,
                                      status: Settings.order_rejected,
                                      user_id: user.id}
    let!(:product_size_1){FactoryBot.create :product_size, size: 34}
    let!(:product_color_1){FactoryBot.create :product_color}
    let!(:product_size_2){FactoryBot.create :product_size, size: 24}
    let!(:product_color_2){FactoryBot.create :product_color, color: "skyss"}
    let!(:product_size_3){FactoryBot.create :product_size, size: 36}
    let!(:product_color_3){FactoryBot.create :product_color}
    let!(:product_size_4){FactoryBot.create :product_size, size: 37}
    let!(:product_color_4){FactoryBot.create :product_color}
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
    let!(:product_detail_3){FactoryBot.create :product_detail, product_id: product_3.id,
                                              product_size_id: product_size_3.id,
                                              product_color_id: product_color_3.id, price: 1000}
    let!(:product_detail_4){FactoryBot.create :product_detail, product_id: product_4.id,
                                              product_size_id: product_size_4.id,
                                              product_color_id: product_color_4.id, price: 1000}
    let!(:order_detail_3) {FactoryBot.create :order_detail,
                                              order_id: order_3.id,
                                              product_detail_id: product_detail_3.id}
    let!(:order_detail_4) {FactoryBot.create :order_detail,
                                              order_id: order_4.id,
                                              product_detail_id: product_detail_4.id}

    describe "Scope By Order Status" do
      context "when found" do
        it "should filter order by status" do
          expect(OrderDetail.by_order_status([Settings.order_confirmed,
                                              Settings.order_shipping,
                                              Settings.order_delivered]))
                            .to eq([order_detail_1, order_detail_2])
        end
      end

      context "when not found" do
        it "should be empty" do
          expect(OrderDetail.by_order_status([-2, -1, -5])).to eq []
        end
      end
    end
  end
end
