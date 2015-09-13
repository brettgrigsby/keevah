class PagesController < ApplicationController
  def update
    session[:page_count] = params[:page_count]
    redirect_to :back
  end
end

