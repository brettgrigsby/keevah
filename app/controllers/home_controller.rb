class HomeController < ApplicationController
  def index
  end

  def not_found
    flash.now[:error] = "Page not found"
    render '404.html'
  end
end
