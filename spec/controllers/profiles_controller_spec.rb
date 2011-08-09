require 'spec_helper'

describe ProfilesController do
  before(:each) do
    @user=Factory(:user)
    test_sign_in(@user)
  end
  describe "GET 'new'" do
    it "should be successful" do
      get 'new', :user_id  => @user.id, :id  => @user.id
      response.should be_success
    end
  end
  describe "POST create" do
    describe 'success' do
      it "should create a new profile" do
        lambda do
          @attr={:about  => "special friendly about"}
          get :new, :user_id  => @user.id
          post :create, :user_id  => @user.id, :profile  => @attr
        end.should change(Profile, :count).by(1)
      end
    end
    describe "failure" do
      it "should not allow non images for the file" do
        @attr={:profile_avatar  => "#{Rails.root}/spec/fixtures/bad_avatar.pdf"}
        get :new, :user_id  => @user.id
        post :create, :user_id  => @user.id, :profile  => @attr
        @user.reload
        @profile=@user.profile
        @profile.avatar_file_name.should be_nil
     end  
    end 
  end

  describe "Existing users" do
    before(:each) do
      @profile=Factory(:profile, :user  => @user)
    end
    describe "GET 'show'" do
      it "should be successful" do
        get :show, :user_id => @user.id, :id  => @profile.id
        response.should be_success
      end
    end
    describe "GET 'edit" do
      it "should be successful" do
        get :edit,  :user_id  => @user.id, :id => @profile
        response.should be_success
      end
    end
    describe "PUT 'update'" do
      before(:each) do
        @attr = {:about  => "a new about!"}
        get :edit, :user_id  => @user.id, :id  => @profile
      end
      it "should redirect to users show" do
        put :update, :user_id  => @user.id, :id  => @profile.id
        response.should redirect_to @user
      end
      it "should update the attributes of the user" do
        put :update, :user_id  => @user.id, :id  => @profile.id, :profile  => @attr
        @profile.reload
        @profile.about.should == "a new about!"
      end
    end  
  end

end
