require 'spec_helper'

describe User do
  before(:each) do
    @attr={:name => "Example User", 
      :email  => "Example@example.com",
      :password => "foobar", 
      :password_confirmation  => "foobar",}
  end
  it "should create a new instance of a user" do
    User.create!(@attr)
  end
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name="a"*51
    long_name_user=User.new(@attr.merge(:name => long_name ))
    long_name_user.should_not be_valid
  end
  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  it "should accept valid email addresses" do
    valid_emails=%w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    valid_emails.each do |email|
      valid_email_user=User.new(@attr.merge(:email=>email))
      valid_email_user.should be_valid
    end
  end
  it "should reject invalid email addresses" do
    invalid_emails=%w[user@foo,com user_at_foo.org example.user@foo.]
    invalid_emails.each do |email|
      invalid_email_user=User.new(@attr.merge(:email => email))
      invalid_email_user.should_not be_valid
    end
  end
  it "should reject duplicate emails" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  it "should reject emails identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password  =>  "")).should_not be_valid
    end
    it "should require a valid password confirmation" do
      User.new(@attr.merge(:password_confirmation=> "invalid")).should_not be_valid
    end
    it "should reject short passwords" do
      User.new(@attr.merge(:password => "w" * 5)).should_not be_valid
    end
    it "should reject long passwords" do
      User.new(@attr.merge(:password => "w" * 41)).should_not be_valid
    end
  end
  describe "password encryption" do
    before(:each) do
      @user=User.create!(@attr)
    end
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    it "should have something as an encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    describe "has password? method" do
      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
      describe "authenticate method" do
        it "should return nil for an email/password mismatch" do
          wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
          wrong_password_user.should be_nil
        end
        it "should return nil if email has no associated user" do
          wrong_email_user = User.authenticate("crazyemail@hootenanny.com", @attr[:password])
          wrong_email_user.should be_nil
        end
        it "should return user for correct email password combo" do
          matching_user=User.authenticate(@attr[:email], @attr[:password])
          matching_user.should==@user
        end
      end
    end
  end
  describe "profile responses" do
    before(:each) do
      @user=User.create(@attr)
    end
    it "should respond to profile attribute" do
      @user.should respond_to(:profile)
    end
  end
  describe "profile responses" do
    before(:each) do
      @user=User.create(@attr)
    end
    it "should respond to profile attribute" do
      @user.should respond_to(:profile)
    end
  end
  describe "forgot password attributes" do
    before(:each) do
      @user=User.create(@attr)
    end
    it "should respond to forgot password code attribute" do
      @user.should respond_to(:reset_password_code)
    end
    it "should respond to forgot password code until attribute" do
      @user.should respond_to(:reset_password_code_until)
    end
  end
  describe "admin attribute" do
    before(:each) do
      @user=Factory(:user)
    end
    it "should respond to admin attribute" do
      @user.should respond_to(:admin)
    end
    it "should not be an admin by default" do
      @user.should_not be_admin
    end
    it "should be convertible to admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  describe "micropost association" do
    before(:each) do
      @user=Factory(:user)
      @mp1 = Factory(:micropost, :user  => @user, :created_at  => 1.day.ago)
      @mp2 = Factory(:micropost, :user  => @user, :created_at  => 1.hour.ago)
    end
    
    it "should respond to micropost" do
      @user.should respond_to (:microposts)
    end
    it "should have microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    it "should destroy the user's microposts when it destroys the user" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    describe "status feed" do
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      it "should include the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp1).should be_true 
      end
      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost, :user  => Factory(:user, :email  => Factory.next(:email))) 
        @user.feed.include?(mp3).should be_false    
      end 
    end
  end
end
