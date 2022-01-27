module Admin::UsersHelper
  def show_activate user
    t "user.#{user.activated? ? 'unactivate' : 'activate'}"
  end
end
