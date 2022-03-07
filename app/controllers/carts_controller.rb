class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_product, only: %i(create)

  def index
    @products = {}

    current_carts.each do |product_detail_id, quantity|
      product_detail = ProductDetail.find_by(id: product_detail_id)
      @products[product_detail] = quantity
    end
  end

  def create
    add_cart params[:id]
    flash[:success] = t "success"
    respond_to do |format|
      format.html{redirect_to request.referer}
      format.js
    end
  end

  def select_cart
    @product_detail = ProductDetail.find_by cart_params

    respond_to do |format|
      format.html{redirect_to request.referer}
      format.js
    end
  end

  def update
    update_quantity_cart params[:product_detail_id], params[:quantity]
    @quantity = params[:quantity].to_i
    @product_detail = ProductDetail.find_by id: params[:product_detail_id]

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @product_detail_id = params[:id]
    delete_item_cart params[:id]

    respond_to do |format|
      format.html{redirect_to request.referer}
      format.js
    end
  end

  private

  def cart_params
    params.permit(:product_size_id,
                  :product_color_id,
                  :product_id)
  end

  def update_quantity_cart product_detail_id, quantity
    current_carts[product_detail_id] = if current_carts.key?(product_detail_id)
                                         quantity.to_i
                                       else
                                         Settings.quantity_defaut_1
                                       end
  end

  def load_product
    @product_detail = ProductDetail.find_by(id: params[:id])
    return if @product_detail.present?

    flash[:warning] = t "not_found"
    if request.xhr?
      render(js: "window.location = '#{request.referer}'") && return
    else
      redirect_to root_path
    end
  end
end
