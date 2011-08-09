class UsersController < ApplicationController
  before_filter :authenticate, :only  => [:edit, :update, :index, :change_password_page, :change_password, :settings]
  before_filter :correct_user, :only  => [:edit, :update, :change_password_page,:change_password, :settings]
  before_filter :admin_user, :only  =>  :destroy
  
  def show
    @user=User.find(params[:id])
    @title=@user.name
    @profile=@user.profile
    @microposts=@user.microposts.paginate(:page  => params[:page])
  end

  def new
    @title = "Sign up"
    @user = User.new
  end    
  def create
    @user=User.new(params[:user])
    if @user.save    
      #UserMailer.registration_confirmation(@user).deliver
      sign_in(@user)
      flash[:success] = "Welcome to the Rails Template!"
      redirect_to @user
    else 
      @title = "Sign up"
      render 'new'
    end
  end
  
  
  def edit
    @user=User.find(params[:id])
    @title="Edit Settings"
  end
  
  def update
    @user=User.find(params[:id])
    @user.updating_password = false
    @user.updating_settings = true
    if @user.update_attributes(params[:user])
      flash[:success]="Settings updated successfully."
      redirect_to @user
    else
      @title="Edit user"
      render "edit"
    end
  end
  def forgot_password_page
    @user=User.new
  end
  
  def forgot_password
    @email = params[:email_find]
    @user = User.find_by_email(@email)  
    if @user
      @user.updating_password = false
      @generated_password=generate_password
      @user.update_attributes(:reset_password_code => @generated_password, :reset_password_code_until => 1.day.from_now)
      @user.save
      #UserMailer.forgot_password(@user).deliver
    flash[:success] = "A temporary password has been emailed to #{@user.email}"
    redirect_to reset_password_path
    else
      flash.now[:error] = "Email #{params[:email_find]} not recognized"
      render "forgot_password_page"
    end 
  end
  
  def reset_password_page
    @user=User.new
  end
  
  def reset_password 
    @user = User.find_by_reset_password_code(params[:reset_password_code]) 
    unless @user.nil? 
      @expiration_time=@user.reset_password_code_until
      unless @expiration_time.nil?   
        if Time.now.utc < @user.reset_password_code_until
          sign_in @user
          flash[:success]="Please create a new password below:"
          redirect_to (change_password_page_path(@user))
        else
          flash[:error]="#{Time.now.utc} and #{@user.reset_password_code_until}Your temporary password code expired - codes are only good for one day.  Type your email below to receive a new code:"
          redirect_to forgot_password_path
        end
      else
        flash.now[:error]="The code you entered is invalid.  Code is case-sensitive, (i.e. capitalized letters matter).  Copy the code from the email, then paste it below."
        render 'reset_password_page'
      end
    else
      flash.now[:error]="The code you entered is invalid. Code is case-sensitive (capitalized letters matter).  Copy the code from the email, then paste it below." 
      render 'reset_password_page'
    end
  end
  def index
    @title="All users"
    @users=User.paginate(:page  => params[:page])
  end
  def change_password_page
    @user=User.find(params[:id])
    @title="Change password"
  end
  def change_password

    @user=User.find(params[:id])
    @user.updating_password = true
    @user.updating_settings = false
    @user.password=params[:password]
    @user.password_confirmation=params[:password_confirmation]
    if @user.save
      sign_in(@user)
      @user.update_attributes(:password => params[:password], :password_confirmation => params[:password])
      sign_in(@user)
      flash[:success]="Password updated successfully."
      redirect_to @user
    else
      @title="Change password"
      render "change_password_page"
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success]= "User destroyed"
    redirect_to users_path
  end
  

  
  private
  def generate_password(length=7)
  	  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
  	  password = ''
  	  length.times { |i| password << chars[rand(chars.length)] }
  	  password
  end

  def admin_user
    redirect_to(root_path) unless current_user and current_user.admin?
  end

end
