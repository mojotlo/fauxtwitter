module ApplicationHelper
  def logo
    @logo=image_tag("logo.png", :alt =>"template app", :class => "round")
  end
  def profile_pic(size, css_class=nil)
    unless @profile
        @profile_pic=image_tag("missing_#{size}.png", :class => css_class)
    else
        @profile_pic=image_tag(@profile.avatar.url(size), :class=>css_class)
    end
  end
  def about_default
    if @user.profile and @profile.about
      @about_default=@profile.about
    else
      @about_default="No information given"
    end
  end
  def conditional_link(display, condition, path)
    if current_user
      if condition
        @conditional_link=link_to(display, path)
      else
        @conditional_link=display
      end
    else @conditional_link=display
    end
  end
  def current_user_is_user?
    if controller.signed_in?
      current_user==@user
    else
      return false
    end
  end
  def should_validate_password?
    updating_password || new_record?
  end

end
