class ApplicationController < ActionController::Base
  include SessionsHelper
  before_action :set_locale

  include Pagy::Backend

  private
  def set_locale
    locale = params[:locale].to_s.strip.to_sym
    I18n.locale = if I18n.available_locales.include?(locale)
                    locale
                  else
                    I18n.default_locale
                  end
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def check_amin
    redirect_to root_path unless current_user.role?
    flash[:danger] = t "not_admin"
  end

  def find_user_by_id
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "find_fail"
    redirect_to root_url
  end

  def check_user_activated
    return if @user.activated

    flash[:danger] = t "user_not_activated"
    redirect_to root_url
  end

  def correct_user
    redirect_to root_path unless current_user? @user
  end
end
