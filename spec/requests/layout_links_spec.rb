require 'spec_helper'

describe "LayoutLinks" do
  describe "GET /layout_links" do
    it "should have a Home page at '/'" do
      get '/'
      response.should have_selector("title", :content => 'Home')
    end
    it "should have a Contact page at '/contact'" do
      get '/contact'
      response.should have_selector("title", :content => 'Contact')
    end
    it "should have an About page at '/about'" do
      get '/about'
      response.should have_selector("title", :content => 'About')
    end
    it "should have a Help page at '/help'" do
      get '/help'
      response.should have_selector("title", :content => 'Help')
    end
    it "should have a signup page at /signup" do
      get '/signup'
      response.should have_selector('title', :content  => "Sign up")
    end
    it "should have the right links on the layout" do
      visit root_path
      click_link "About"
      response.should have_selector("title", :content => "About")
      click_link "Help"
      response.should have_selector("title", :content => "Help")
      click_link "Contact"
      response.should have_selector("title", :content => "Contact")
      click_link "Home"
      response.should have_selector("title", :content => "Home")
      click_link "Sign up now!"
      response.should have_selector("title", :content => "Sign up")
    end  
  end
  describe "when not signed in" do
    it "should have a signin link" do
      visit root_path
      response.should have_selector("a", :href  => signin_path,
                                          :content  => "Sign in")
    end
  end
  describe "when signed in" do
    before(:each) do
      @user = Factory(:user)
      visit signin_path 
      fill_in "session[email]",  :with  => @user.email
      fill_in "session[password]",  :with  => @user.password
      click_button
    end
    
    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path,
                                          :content  => "Sign out")
    end
    it "should have a profile link" do
      response.should have_selector("a", :href  => user_path(@user),
                                    :content  => 'Profile')
    end
    it "should have a create profile link" do
      response.should have_selector("a", :href  => new_user_profile_path(@user), :content  => 'Create Profile')
    end
    it "should have a settings link" do
      response.should have_selector("a", :href  => settings_path(@user), :content  => 'Settings')
    end
    it "should have a change password link" do
      response.should have_selector("a", :href  => change_password_page_path(@user), :content  => 'Change Password')
    end
    describe "when profile exists" do
      it "should have an edit profile button" do
        visit new_user_profile_path(@user)
        fill_in /about/i, :with  => "Some stuff about me"
        click_button
        visit root_path
        response.should have_selector("a", :href  => edit_user_profile_path(@user, @user.profile), :content  => "Edit Profile")
        click_link "Edit Profile"
        response.should be_success
      end
    end
  end
  describe "FriendlyForwardings" do
    it "should forward to the requested page after signin" do
      user=Factory(:user)
      visit edit_user_path(user) 
      #the test automatically follows the redirect page to the signin page
      fill_in "session[email]", :with  => user.email
      fill_in "session[password]", :with  => user.password
      click_button
      #the test follows the redirect again, this time to user/edit
      response.should render_template('users/edit')
    end
  end
end
