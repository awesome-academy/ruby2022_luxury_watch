class Order < ApplicationRecord
  belongs_to :user
  has_one :discount, dependent: :destroy
  has_many :order_details, dependent: :destroy
  has_many :products, through: :order_details
end
