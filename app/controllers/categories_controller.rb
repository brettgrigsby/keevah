class CategoriesController < ApplicationController
  def index
    @category = Category.all
  end

  def show
    @categories = Category.all
    @category = Category.find(params[:id])
    loan_requests = @category.loan_requests
    load_page(loan_requests, page_count)
    @loan_requests = Pager.page(loan_requests, @page[:current], page_count)
  end
end
