class User < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :comment_rates, dependent: :destroy
  has_many :products, through: :comment_rates

  attr_accessor :remember_token, :activation_token, :reset_token

  scope :newest, ->{order created_at: :desc}
  before_create :create_activation_digest
  before_save :downcase_email

  validates :name, presence: true,
            length: {maximum: Settings.length_digit_255}
  validates :email, presence: true,
            length: {maximum: Settings.length_digit_255},
            format: {with: Settings.email_regex},
            uniqueness: true
  validates :password, presence: true,
            length: {minimum: Settings.length_digit_6},
            allow_nil: true

  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password? token
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def update_activated
    update_column :activated, !@user.activated
  end

  def send_active_mail
    UserMailer.account_activation(self).deliver_now
  end

  def forget
    update_column :remember_digest, nil
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def password_reset_expired?
    reset_sent_at < Settings.expired_password_time.hours.ago
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                  reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  private
  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
