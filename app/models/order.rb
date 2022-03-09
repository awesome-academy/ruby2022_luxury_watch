class Order < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  belongs_to :discount, optional: true
  has_many :order_details, dependent: :destroy
  has_many :products, through: :order_details
  enum status: {
    wait: 0,
    confirmed: 1,
    shipping: 2,
    delivered: 3,
    rejected: 4,
    returned: 5
  }
  delegate :name, :email, to: :user, prefix: :user
  # validates :user_name_at_order, presence: true
  # validates :address_at_order, presence: true
  scope :by_status,
        ->(type){where("status = ?", type) if type}
  scope :by_product, (lambda do |pro_ids|
    left_joins(order_details: {product_detail: [:product]})
    .where(product: {id: pro_ids})
  end)

  def status_buy_again?
    delivered? || returned? || rejected?
  end

  scope :newest, ->{order created_at: :desc}
end
