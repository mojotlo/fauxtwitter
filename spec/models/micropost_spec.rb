require 'spec_helper'

describe Micropost do
  before(:each) do
    @user=Factory(:user)
    @attr={:content  => "This is a tiny post"}
  end
  it "should create a micropost given valid attributes" do
    Micropost.create!(@attr)
  end
  describe "User associations" do
    before (:each) do
      @micropost=@user.microposts.create(@attr)
    end
    it "should have a user" do
      @micropost.should respond_to(:user)
    end
    it "should have the right associated user" do
      @micropost.user_id.should == @user.id   
      @micropost.user.should == @user    
    end
  end
  describe "valid microposts" do
    it "should not create a blank micropost" do
      @micropost=@user.microposts.build(:content  => " ").should_not be_valid
    end
    it "should reject long microposts" do
      @micropost=@user.microposts.build(:content  => "a"*121).should_not be_valid
    end
  end
end
