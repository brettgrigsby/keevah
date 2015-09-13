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

  def load_page(klass, count)
    @page ||= {}
    page = params[:page] || 1
    page == "last" ? @page[:current] = Pager.last(klass, count) : @page[:current] = page.to_i
    @page[:total] = klass.count / count.to_i
  end

  def page_count
    session[:page_count] ||= 24
  end

  helper_method :create_cart, :current_user, :current_borrower?, :number_of_pages
end
