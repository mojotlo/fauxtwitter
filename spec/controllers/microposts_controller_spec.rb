require 'spec_helper'

describe MicropostsController do
  render_views
  describe "access control" do
    describe "create" do
      before(:each) do
        @user=Factory(:user)
        @attr={:content => "This is some micro-content"}
      end
      describe "failure" do        
        it "should deny un-logged in users' attempts to create microposts" do
          post :create, :micropost  => @attr
          response.should redirect_to(signin_path)
        end
      end
      describe "success" do
        before(:each) do
          test_sign_in(@user)
        end
        it "should allow the user to create a micropost" do
          post :create, :micropost  => @attr
          response.should redirect_to(root_path)
        end
        it "should increase the number of microposts by one" do
          lambda do
            post :create,   :micropost  => @attr
          end.should change(Micropost, :count).by(1)
        end
        it "should have a flash success message" do
          post :create, :micropost  => @attr
          flash[:success].should=~/Micropost created/i
        end
      end
    end
    describe "destroy" do
      before(:each) do
        @user=Factory(:user)
        @micropost=Factory(:micropost, :user => @user)
      end
      describe "for an unauthorized user" do
        before(:each) do
          wrong_user=Factory(:user, :email  => Factory.next(:email))
          test_sign_in(wrong_user)
        end
        it "should deny un-logged in users' attempts to destroy microposts" do
          delete :destroy, :id  => @micropost
          response.should redirect_to(root_path)
        end
      end
      describe "for an authorized user" do
        before(:each) do
          test_sign_in(@user)
        end
        it "should reduce the number of microposts by one" do
          lambda do 
            delete :destroy, :id  => @micropost
          end.should change(Micropost, :count).by(-1)
        end
      end
    end
  end
end