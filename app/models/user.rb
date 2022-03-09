class User < ApplicationRecord
  acts_as_paranoid
  PROPERTIES = %i(name email address phone password
                  password_confirmation remember_me).freeze
  devise :database_authenticatable, :registerable, :validatable,
         :confirmable, :recoverable, :rememberable,
         :trackable, :timeoutable, :lockable,
         :omniauthable, omniauth_providers: %i(google_oauth2)
  has_many :orders, dependent: :destroy
  has_many :comment_rates, dependent: :destroy
  has_many :products, through: :comment_rates

  enum role: {user: Settings.user, admin: Settings.admin}

  scope :newest, ->{order created_at: :desc}
  before_save :downcase_email

  validates :name, presence: true,
            length: {maximum: Settings.length_digit_255}
  scope :search_by_name,
        ->(name){where("LOWER(name) LIKE ?", "%#{name.downcase}%") if name}

  scope :by_role,
        ->(role){where("role = ?", role.to_s) if role}

  class << self
    def from_omniauth auth
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.info.name
        user.skip_confirmation!
        user.save
      end
    end
  end

  private
  def downcase_email
    email.downcase!
  end

  def timeout_in
    return Settings.number_10.days if admin?

    Settings.number_1.year
  end
end
