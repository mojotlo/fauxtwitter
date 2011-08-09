require 'spec_helper'

describe UsersController do
  render_views

  describe "Get 'show'" do
    before(:each) do
      @user=Factory(:user)
    end
    describe "for non-signed in users" do
      it "should be successful" do
        get  :show, :id => @user
        response.should be_success
      end
      it "should find the right user" do
        get :show, :id => @user
        assigns(:user).should == @user
      end
     it "should have a profile pic" do
       get :show, :id  =>  @user
       response.should have_selector("img", :class  => "profile_pic")
     end
      it "should include the user's name" do
        get :show, :id  => @user
        response.should have_selector("h1", :content  => @user.name)
      end
      it "should include the user's about section or a default" do
        get :show, :id  => @user
        response.should have_selector("p", :content  => "No information given")
      end
      it "should have microposts" do
        @mp1=Factory(:micropost, :user=>@user, :content => "Hunky donk")
        @mp2=Factory(:micropost, :user=>@user, :content => "check out my lynx")        
        get :show, :id  => @user
        response.should have_selector("span", :content  => @mp1.content)
        response.should have_selector("span", :content  => "check out my lynx")
      end
    end      
    describe "for signed in users" do
      describe "for one user looking at another user's profile" do
        before (:each) do
           test_sign_in(@user)
          @user2=Factory(:user, :email  => "example4000@example.com")
        end
        it "should allow one user to look at another user" do
          get :show, :id  => @user2
          response.should be_success
        end
        it "should not have links to change the profile" do
          get :show, :id  => @user2
          response.should_not have_selector("p>a", :href => new_user_profile_path(@user))
          response.should_not have_selector("p>a", :href  => edit_user_profile_path(@user))
        end
      end
      describe "for a user looking at her own profile" do
        before(:each) do
          test_sign_in(@user)
        end
        it "should allow a user to view their own profile" do
          get :show, :id  => @user
          response.should be_success
        end
        it "should include links to profile/new if no profile exists" do
          get :show, :id  => @user
          response.should have_selector("p > a", :href  => new_user_profile_path(@user), :content => "No information given") 
        end
        it "should include links to profile/edit if profile exists" do
          @profile=Factory(:profile, :user  => @user)
          get :show, :id  => @user
          response.should have_selector("p > a", :href  => edit_user_profile_path(@user)) 
        end
      end
    end
  end
  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    it "should have the right title" do
      get 'new'
      response.should have_selector('title', :content  => "Sign up")
    end
  end
  describe "POST :create" do
    describe "failure" do
      before (:each) do
        @attr = {:name  => "", :email  => "",
        :password  => "", :password_confirmation  => ""}
      end
      it 'should not create a user' do
        lambda do
          post :create, :user  => @attr
        end.should_not change(User, :count)
      end
      it "should have the right title" do
        post :create, :user  => @attr
        response.should have_selector("title", :content  => "Sign up")
      end
      it "should render the :new page" do
        post :create, :user  => @attr 
        response.should render_template('new')
      end
    end
    describe "success" do
      before (:each) do
        @attr = {:name  => "Joe", :email  => "Joe@gmi.com",
        :password  => "Joe@gmi.com", :password_confirmation  => "Joe@gmi.com"}
      end
      it "should create a user" do
        lambda do
          post :create, :user  => @attr
        end.should change(User, :count).by(1)
      end
      it "should redirect to the :user show page" do
        post :create, :user  => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end
      it "should have a welcome message" do
        post :create, :user  => @attr
        flash[:success].should =~ /welcome to the rails template/i
      end
      it "should sign the user in" do
        post :create, :user  => @attr
        controller.should be_signed_in
      end
    end
  end
  describe "GET 'edit" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    it "should be successful" do
      get 'edit', :id  => @user
      response.should be_success
    end
    it "should have the right title" do
      get :edit, :id  => @user
      response.should have_selector('title',
                                    :content  => 'Edit')
    end
  end
  describe "POST 'update'" do
    before(:each) do
      @user=Factory(:user)
      test_sign_in(@user)
    end
    describe "failure" do
      before(:each) do
        @attr = {:name  => "", :email  => ""}
      end
      it "should render the edit page" do
        get :edit, :id  => @user
        put :update, :id => @user, :user  => @attr 
        response.should render_template('edit')
      end
      it "should have the right title" do
        get :edit, :id  => @user
        put :update, :id => @user, :user  => @attr
        response.should have_selector("title", :content => "Edit user")
      end
    end
    describe "success" do
      before(:each) do
        @attr = {:name  => "Michael Hartl", :email => "newemail@email.com"}
      end
      it "should update the user attributes" do
        put :update, :id  => @user, :user  => @attr
        @user.reload
        @user.email.should==@attr[:email]
        @user.name.should==@attr[:name]
      end
      it "should redirect to the user/show page" do
        put :update, :id  => @user, :user  => @attr
        response.should redirect_to(user_path(@user))
      end
      it "should have a flash message" do
        put :update, :id  => @user, :user  => @attr
        flash[:success].should =~/updated/i
      end
    end
  end  
  describe "authentication of edit/update/change_password pages" do
    before(:each) do
      @user = Factory(:user)
    end
    describe "for non-signed in users" do  
      it "should deny access to edit" do
        get :edit, :id  => @user
        response.should redirect_to(signin_path)
      end
      it "should deny access to update" do
        put :update, :id  => @user, :user  => {}
        response.should redirect_to(signin_path)
      end
      it "should deny access to change password page" do
        get :change_password_page, :id  => @user, :user  => {}
        response.should redirect_to(signin_path)
      end
      it "should deny access to the change password action" do
        post :change_password, :id  => @user, :user  => {}
        response.should redirect_to(signin_path)
      end
    end
    describe "for signed-in users" do
      before(:each) do
        wrong_user=Factory(:user, :email  => "user@example.net")
        test_sign_in(wrong_user)
      end
      it "should require matching users for edit" do
        get :edit, :id  => @user
        response.should redirect_to(root_path)
      end
      it "should require matching users for update" do
        put :update, :id  => @user, :user  => {}
        response.should redirect_to(root_path)
      end
      it "should require matching users for change password page" do
        get :change_password_page, :id  => @user, :user  => {}
        response.should redirect_to(root_path)
      end
      it "should require matching users for change password action" do
        post :change_password, :id  => @user, :user  => {}
        response.should redirect_to(root_path)
      end
    end
  end 
  describe "GET 'index'" do
    describe "for non-signed in users" do
      it "should deny access" do
        get 'index'
        response.should redirect_to(signin_path)
        flash[:notice].should=~/signed in/i
      end
    end
    describe "for signed in users" do
      before(:each) do
        @user=test_sign_in(Factory(:user))
        second=Factory(:user, :email  => "secondemail@email.com")
        third=Factory(:user, :email  => "third@email.com")
        @users=[@user, second, third]      
      end
      it "should be successful" do
        get :index
        response.should be_success
      end
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end
      it "should have an element for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end 
      it "should have a photo for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("img")
        end
      end
      it "should paginate users" do
        30.times do
          @users << Factory(:user, :email  => Factory.next(:email)) 
        end
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href  => "/users?page=2", 
                                      :content => "2")
        response.should have_selector("a", :href  => "/users?page=2", 
                                        :content=> "Next")
      end
    end  
  end
  describe "'DELETE' destroy" do
    before(:each) do
      @user=Factory(:user)
    end
    describe "as a non-signed in user" do
      it "should deny access" do
        delete :destroy, :id  => @user
        response.should redirect_to(root_path)
      end
    end
    describe "as a non-admin user" do
      it "should protect the action" do
        test_sign_in(@user)
        delete :destroy, :id  => @user
        response.should redirect_to(root_path)
      end
      it "should not have a delete link at users show" do
        test_sign_in(@user)
        get :index
        response.should_not have_selector("a", :content  => "delete")
      end        
    end
    describe "as an admin user" do
      before(:each) do
        admin=Factory(:user, :email  => "admin@example.com", :admin  => true)
        test_sign_in(admin)
      end
      it "should destroy the user" do
        lambda do
          delete :destroy, :id  => @user
        end.should change(User, :count).by(-1)
      end
      it "should redirect to users path" do
        delete :destroy, :id  => @user
        response.should redirect_to(users_path)
      end
      it "should have a delete link at users index" do
        get :index
        response.should have_selector("a", :content  => "delete")
      end
    end
  end
  describe "forgot password" do

    it "GET should have a page at forgot_password" do   
      get :forgot_password_page
      response.should be_success
    end
    describe "POST forgot password" do
      describe "success" do
        before(:each) do
          @user=Factory(:user)
          @email=@user.email
          post :forgot_password, :email_find  => @email
        end
        it "should create a forgot_password_code if given an email" do
          post :forgot_password, :email_find  => @email
          @user.reload
          @user.reset_password_code.should_not be_nil      
        end
        it "should create a forgot_password_code_until attribute" do
          post :forgot_password, :email_find  => @email 
          @user.reload
          @user.reset_password_code_until.should_not be_nil
        end
        it "should have a forgot_password_code_until that is in the future" do
          post :forgot_password, :email_find  => @email
          @user.reload
          @user.reset_password_code_until.should be > Time.now
        end
        it "should have an until token that expires in fewer than two days" do
           post :forgot_password, :email_find  => @email
          @user.reload
          @user.reset_password_code_until.should be < 2.days.from_now
        end
        it "should redirect the user to reset password" do
          post :forgot_password, :email_find  => @email
          response.should redirect_to(reset_password_path)
        end
        it "should redirect the user to reset password" do
         post :forgot_password, :email_find  => @email
          flash[:success].should=~/temporary password/i
        end        
      end
      describe "failure" do
        before(:each) do
          @user=Factory(:user)          
          post "forgot_password", :email  => "impossibleemail"
          @user.reload
        end
        it "should not create a forgot_password_code if given an incorrect email" do
          @user.reset_password_code.should be_nil      
        end
        it "should render the forgot password page" do
          response.should render_template (:forgot_password)
          flash[:error].should=~/not recognized/i
        end
      end
    end
  end
  describe "reset password" do
    before(:each) do
      @user=Factory(:user)
    end
    describe "GET" do
      it "should have a page at reset_password" do
        get 'reset_password'
        response.should be_success
      end
      it "should ask for a reset code within a form" do
       get :reset_password_page
       response.should have_selector("label", :content  => "code")
      end
    end
    describe "POST reset_password" do

      describe "wrong code failure" do
        it "should render the reset password page with an error message" do
          @incorrect_code="gen e rate pass word".split.shuffle.join
          post :reset_password, :reset_password_code => @incorrect_code
          response.should render_template(:reset_password)
          flash.now[:error].should =~ /invalid/i
        end
      end

      describe "expired code failure" do
        it "should render the forgot password page with an error message" do
          @user.update_attributes(:reset_password_code_until => 1.day.ago, :reset_password_code => "wW4ekwW")
          post :reset_password, :reset_password_code  => @user.reset_password_code
          response.should redirect_to(:forgot_password)
          flash[:error].should =~ /expired/i

        end
      end
      describe "success" do
        before(:each) do
          @user.update_attributes(:reset_password_code_until => 1.day.from_now, :reset_password_code => "wW4ekwW")
          post :reset_password, :reset_password_code  => @user.reset_password_code
        end
        it "should render the user edit page" do
          response.should redirect_to(change_password_page_path(@user))
          flash[:success].should =~ /new password/i       
        end
        it "should sign in the user" do
          controller.current_user.should == @user
          controller.should be_signed_in
        end
      end
    end
  end
  describe "change password" do
    describe "success" do
      before(:each) do
        @user = Factory(:user)
        @password = "newpass"
        @password_confirmation = "newpass"
        test_sign_in(@user)
      end
      it "should render the user/show page if password is good " do
        post :change_password, :id  => @user.id, :password  =>  @password, :password_confirmation  => "newpass"
        response.should redirect_to user_path(@user)
      end   
      it "should sign the user in" do
         post :change_password, :id  => @user.id, :password  =>  @password,      
           :password_confirmation  => @password_confirmation
        controller.current_user.should == @user
        controller.should be_signed_in      
      end
      it "should change the encrypted password" do
        @encrypted_password=@user.encrypted_password
        post :change_password, :id  => @user.id, :password  =>  @password,      
          :password_confirmation  => @password_confirmation
        @user.reload
        @new_enc_pass=@user.encrypted_password
        @encrypted_password.should_not == @new_enc_pass
      end
    end
    describe 'failure' do
      before(:each) do
        @user = Factory(:user)
        @password = "longbad"
        @password2 = "bad"
        test_sign_in(@user)
      end
      it "should rerender change password page if password not confirmed " do
        post :change_password, :id  => @user.id, :password  =>  @password, :password_confirmation  => ""
        response.should render_template (:change_password_page)
      end
      it "should rerender change password page if password too short" do
        post :change_password, :id  => @user.id, :password  =>  @password2, :password_confirmation  => @password2
        response.should render_template(:change_password_page)
      end
      it "should not change the encrypted password" do
        @encrypted_password=@user.encrypted_password       
        post :change_password, :id  => @user.id, :password  =>  @password, :password_confirmation  => @password2 
        @user.reload
        @new_enc_pass=@user.encrypted_password
        @encrypted_password.should == @new_enc_pass
      end  
    end 
  end
end

    

