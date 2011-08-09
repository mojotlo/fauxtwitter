class ProfilesController < ApplicationController
 before_filter :authenticate
 before_filter :has_profile?, :only  => [:new, :create]
 before_filter :correct_user
 

 def new
    @user=User.find(params[:user_id])
    
    @title = "Create a profile"
    @profile = @user.create_profile(params[:profile])

 end
 def create
   @profile.save
    flash[:success] = "Check out your new profile"
    redirect_to @user
 end
 def edit
   @title="Edit Profile"
   @user=User.find(params[:user_id])
   @profile=@user.profile
 end

 def update
   @title="Edit Profile"
   @user=User.find(params[:user_id])
   @profile=@user.profile
    if @profile.update_attributes(params[:profile])
      flash[:success]="Profile updated successfully."
      redirect_to @user
    else
      @title="Edit profile"
      render "edit"
    end
 end
end
