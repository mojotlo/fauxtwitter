module SessionsHelper
  def redirect_to_profile_edit
    redirect_to :edit if has_profile?
  end
  def has_profile?
    !current_user.profile.nil?
  end
  def sign_in(user) #called by sessions controller for successfully authenticated users
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    current_user = user
  end
  def current_user=(user)#called by sign_in(user) 
    @current_user = user
  end #this function allows for assignment to the current_user variable without the use of attr_accessor
  def current_user #called throughout the application to return the current user
    @current_user ||= user_from_remember_token #use @current_user or define it
  end
  def signed_in?
    !current_user.nil?
  end
  def sign_out
    cookies.delete(:remember_token)
    current_user = nil
  end
  
  def current_user?(user) #used for authentication of owned resources
    user==current_user
  end
  def authenticate #used in a before filter in controllers to keep out logged out users
    deny_access unless signed_in?
  end
  def deny_access
    store_location
    redirect_to signin_path, :notice  => "You must be signed in to view this page."
  end
  def redirect_back_or(default)
    redirect_to (session[:return_to] || default)
    clear_return_to
  end
  def correct_user
    @id = params[:id] || params[:user_id]
    @user = User.find(@id)
    redirect_to(root_path) unless current_user?(@user)
  end
  private
    def store_location
      session[:return_to]=request.fullpath
    end
    def clear_return_to
      session[:return_to]=nil
    end
    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end
    
    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end

end
