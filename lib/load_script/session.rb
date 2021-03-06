require "logger"
require "pry"
require "capybara"
require 'capybara/poltergeist'
require "faker"
require "active_support"
require "active_support/core_ext"

module LoadScript
  class Session
    include Capybara::DSL
    attr_reader :host
    def initialize(host = nil)
      Capybara.default_driver = :poltergeist
      @host = host || "http://localhost:3000"
    end

    def logger
      @logger ||= Logger.new("./log/requests.log")
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def run
      while true
        run_action(actions.sample)
      end
    end

    def run_action(name)
      benchmarked(name) do
        send(name)
      end
    rescue Capybara::Poltergeist::TimeoutError, Capybara::Poltergeist::StatusFailError
      logger.error("Timed out executing Action: #{name}. Will continue.")
    end

    def benchmarked(name)
      logger.info "Running action #{name}"
      start = Time.now
      val = yield
      logger.info "Completed #{name} in #{Time.now - start} seconds"
      val
    end

    def actions
      [:browse_loan_requests, :sign_up_as_lender, :browse_categories,
      :browse_category_pages, :lender_makes_loan, :borrower_creates_loan_request]
    end

    def log_in(email="demo+horace@jumpstartlab.com", pw="password")
      log_out
      session.visit host
      session.click_link("Log In")
      session.fill_in("email_address", with: email)
      session.fill_in("password", with: pw)
      session.click_link_or_button("Login")
    end

    def browse_loan_requests
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
    end

    def log_out
      session.visit host
      if session.has_content?("Log out")
        session.find("#logout").click
      end
    end

    def new_user_name
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def new_request_title
      "#{Faker::Commerce.product_name} #{Time.now.to_i}"
    end

    def new_request_description
      Faker::Company.catch_phrase
    end

    def request_by_date
      Faker::Time.between(7.days.ago, 3.days.ago)
    end

    def repayment_date
      Faker::Time.between(3.days.ago, Time.now)
    end

    def new_user_email(name)
      "TuringPivotBots+#{name.split.join}@gmail.com"
    end

    def sign_up_as_lender(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-lender").click
      session.within("#lenderSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def sign_up_as_borrower(name = new_user_name)
      log_out
      session.visit "#{host}"
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-borrower").click
      session.within("#borrowerSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button("Create Account")
      end
    end

    def browse_categories
      session.visit "#{host}/browse"
      session.within("#categories-list") do
        session.all("a").sample.click
      end
    end

    def browse_category_pages
      browse_categories
      session.all(".page-link").sample.click
    end

    def lender_makes_loan
      sign_up_as_lender
      session.visit "#{host}/browse"
      session.all(".contrib-btn").sample.click
      session.click_on("Basket")
    end

    def borrower_creates_loan_request
      sign_up_as_borrower
      session.click_on("Create Loan Request")
      session.within("#loanRequestModal") do
        session.fill_in("loan_request_title", with: new_request_title)
        session.fill_in("loan_request_description", with: new_request_description)
        session.fill_in("loan_request_requested_by_date", with: request_by_date)
        session.fill_in("loan_request_repayment_begin_date", with: repayment_date)
        session.select("Agriculture", from: "loan_request_category")
        session.fill_in("loan_request_amount", with: "100")
        session.click_link_or_button("Submit")
      end
    end

    def categories
      ["agriculture", "education", "community", "fun money", "architectural",
      "philanthropic", "vehicle", "new home", "new pet", "livestock",
      "equipment", "vacation", "new child", "political campaign"]
    end
  end
end
