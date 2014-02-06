module SessionsHelper
  
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end
  
  def sign_out
    current_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end
  
  def signed_in?
    !current_user.nil?
  end
end

# Three current_user variables:
#   self.current_user
#     Without "self", the assignment would create a local variable  Using self ensures that assignment sets the users's attribute
#   @current_user
#     Accesses the instance variables.
#   current_user
#     Calls the getter/setter
#
# Why 3... what's the difference?  Do they all point to the same thing?