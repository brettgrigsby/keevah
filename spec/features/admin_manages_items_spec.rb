require "rails_helper"

RSpec.feature "admin views the admin dashboard" do
  let(:admin) { User.create(email: "example@example.com", password: "password", role: 1) }

  def add_new_item(title, description, price)
    fill_in 'Title', with: title
    fill_in 'Description', with: description
    fill_in 'Price', with: price
    click_button 'Create Item'
  end

  xscenario "clicks on manage items" do
    admin
    create(:item)
    visit "/login"
    fill_in("session[email]", with: admin.email)
    fill_in("session[password]", with: admin.password)
    click_link_or_button "Login"
    click_link_or_button "Manage Items"
    expect(page).to have_content("Sushi")
  end

  xscenario "clicks on add item" do
    admin
    visit "/login"
    fill_in("session[email]", with: admin.email)
    fill_in("session[password]", with: admin.password)
    click_link_or_button "Login"
    click_link_or_button "Add Item"
    add_new_item "Sushi Roll", "A Roll Of Sushi", 8.45
    expect(page).to have_content("Sushi Roll")
  end
end

  #need to eventually test that it is given a status of 0 by default
  #also will need to change schema and default value like with user role