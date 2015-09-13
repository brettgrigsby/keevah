class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :create_cart

  def create_cart
    @current_cart = Cart.new(session[:cart])
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_borrower?
    current_user && current_user.borrower?
  end

  def load_page
    page = params[:page] || 1
    @page = page.to_i
  end

  helper_method :create_cart, :current_user, :current_borrower?
end
