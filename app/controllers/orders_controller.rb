class OrdersController < ApplicationController
  before_action :authenticate_user!
  load_resource only: %i(show update)
  authorize_resource
  before_action :init_order, only: %i(create)
  before_action :show_cart, only: %i(new)
  before_action :update_status, only: %i(update)

  def index
    if params[:q] && params[:q][:name_cont]
      search_orders
    else
      @q = current_user.orders.includes(:order_details).ransack(params[:q])
      @orders = @q.result
    end
    @pagy, @orders = pagy @orders, items: Settings.number_10
  end

  def new; end

  def create
    ActiveRecord::Base.transaction do
      @order.save!
      CreateOrderDetailJob.perform_now @order, current_carts
    end
    handle_success_order
  rescue NoMethodError
    handle_exception
  end

  def show; end

  def update
    respond_to do |format|
      format.html{redirect_to request.referer}
      format.js
    end
  end

  private
  def order_params
    params.permit :user_name_at_order,
                  :address_at_order,
                  :discount_id
  end

  def init_order
    @order = current_user.orders.new order_params
    @order.status = Settings.order_wait
  end

  def handle_success_order
    current_carts.clear
    flash[:success] = t "success"
    redirect_to root_url
  end

  def handle_exception
    flash.now[:danger] = t "error"
    redirect_to root_url
  end

  def update_status
    return buy_again_order if @order.status_buy_again?

    return @order.rejected! if @order.wait?
  end

  def search_orders
    @q = Product.by_product_of_order(current_user.id)
                .ransack(params[:q])
    pro_ids = @q.result.pluck(:product_id)
    @orders = current_user.orders
                          .by_product(pro_ids)
  end

  def buy_again_order
    @order.order_details.each do |odt|
      add_cart odt.product_detail_id, odt.quantity
    end
    redirect_to cart_path
  end
end
