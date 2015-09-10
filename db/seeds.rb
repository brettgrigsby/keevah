require "populator"

class Seed
  def run
    put_requests_in_categories
    create_orders
  end

  def lenders
    User.where(role: 0)
  end

  def borrowers
    User.where(role: 1)
  end

  def orders
    Order.all
  end

  def create_known_users
    User.create(name: "Jorge", email: "jorge@example.com", password: "password")
    User.create(name: "Rachel", email: "rachel@example.com", password: "password")
    User.create(name: "Josh", email: "josh@example.com", password: "password", role: 1)
  end

  def create_lenders(quantity)
    User.populate(quantity) do |user|
      user.name = Faker::Name.name
      user.email = Faker::Internet.email
      user.password_digest = "$2a$10$hmlfV8ZNxHs4AbxkT8iI9eTsewEyxZ/H5x4iaW5W8VSYzMeSB3OWK"
      user.role = 0
    end
  end

  def create_borrowers(quantity)
    User.populate(quantity) do |user|
      user.name = Faker::Name.name
      user.email = Faker::Internet.email
      user.password_digest = "$2a$10$hmlfV8ZNxHs4AbxkT8iI9eTsewEyxZ/H5x4iaW5W8VSYzMeSB3OWK"
      user.role = 1
    end

    borrowers.each do |borrower|
      LoanRequest.populate(17) do |request|
        request.title = Faker::Commerce.product_name
        request.description = Faker::Company.catch_phrase
        request.status = [0, 1].sample
        request.requested_by_date = Faker::Time.between(7.days.ago, 3.days.ago)
        request.repayment_begin_date = Faker::Time.between(3.days.ago, Time.now)
        request.amount = "200"
        request.contributed = "0"
        request.user_id = borrower.id
        request.repayment_rate = 1
      end
    end
  end

  def create_categories
    ["agriculture", "community", "education"].each do |cat|
      Category.create(title: cat, description: cat + " stuff")
    end
  end

  def put_requests_in_categories
    categories = Category.all
    LoanRequest.all.each do |request|
      categories.sample.loan_requests << request
    end
  end

  def create_orders
    loan_requests = LoanRequest.all
    possible_donations = %w(25, 50, 75, 100, 125, 150, 175, 200)
    loan_requests.each do |request|
      donate = possible_donations.sample
      lender = User.where(role: 0).order("RANDOM()").take(1).first
      order = Order.create(cart_items:
                           { "#{request.id}" => donate },
                           user_id: lender.id)
      order.update_contributed(lender)
    end
  end
end

Seed.new.run
