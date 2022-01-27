class Admin::AdminController < ApplicationController
  before_action :check_amin

  layout "admin"
end
