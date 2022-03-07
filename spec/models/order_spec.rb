require 'rails_helper'

RSpec.describe Order, type: :model do
  it "is valid with valid attributes" do
    expect(Order.new).to_not be_valid
  end

  describe "Scopes" do
    let!(:user){FactoryBot.create :user, name: "tuongabc"}
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
    let!(:product_color_2){FactoryBot.create :product_color, color: "skyss"}
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

    describe "scope newest" do
      context "with scope newest" do
        it "return list recent order by create at DESC" do
          expect(Order.newest).to eq([order_2, order_1])
        end
      end
    end

    describe "with scope by_status" do
      it "return list order by status" do
        expect(Order.by_status(Settings.order_delivered)).to eq([order_2])
      end
    end

    describe "scope by_product" do
      context "when found" do
        it "should filter products by product id" do
          expect(user.orders.by_product([product_1.id, product_2.id])).to eq [order_1, order_2]
        end
      end

      context "when not found" do
        it "should be empty" do
          expect(user.orders.by_product([-2, -1])).to eq []
        end
      end
    end
  end

  describe "Stauts order" do
    let!(:user){FactoryBot.create :user}
    let!(:order_1){FactoryBot.create :order,
                                     status: Settings.order_delivered,
                                     user_id: user.id}

    it "return order can buy again" do
      expect(order_1).to be_status_buy_again
    end
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:discount).optional(:true) }
    it { should have_many(:order_details).dependent(:destroy) }
  end

  describe "Delegates" do
    it { should delegate_method(:name).to(:user).with_prefix(true) }
    it { should delegate_method(:email).to(:user).with_prefix(true) }
  end

  describe "enums" do
    it "define status as an enum" do
      should define_enum_for(:status)
    end
  end
end
