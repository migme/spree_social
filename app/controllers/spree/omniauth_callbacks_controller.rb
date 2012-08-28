class Spree::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Spree::Core::ControllerHelpers

  def facebook
    if request.env["omniauth.error"].present?
      flash[:error] = t("devise.omniauth_callbacks.failure", :kind => auth_hash['provider'], :reason => t(:user_was_not_valid))
      redirect_back_or_default(root_url)
      return
    end

    authentication = Spree::UserAuthentication.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])

    if !authentication.nil? && authentication.user
      login_user = authentication.user
      case
        when login_user && login_user.confirmed?
          flash[:success] = "Signed in successfully."
          sign_in_and_redirect :user, login_user
        when login_user && (!login_user.confirmed? || !login_user.activated?)
          login_user.completed_sign_up!
          session[:just_activated] = true
          session[:registering_user_id] = nil
          redirect_to root_url
        else
          raise "#{login_user.id} - has error when try to authenticate with Facebook"
      end
    else
      if current_user
        current_user.completed_sign_up! if Spree::User::INCOMPLETE_STATES.include?(current_user.state_name)
        current_user.user_authentications.create!(:provider => auth_hash['provider'], :uid => auth_hash['uid'])
        flash[:success] = "Authentication successful."
        @user = current_user
      else
        # Register new account
        @user = Spree::User.apply_omniauth(auth_hash, session[:affiliate_code])
        sign_in(:user, @user)
      end
      session[:registering_user_id] = nil
      if !@user.has_role?('auction_user')
        session[:just_activated] = true
      end
      redirect_to(root_url)
    end
  end

  def failure
    set_flash_message :alert, :failure, :kind => failed_strategy.name.to_s.humanize, :reason => failure_message
    redirect_to spree.login_path
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def auth_hash
    request.env["omniauth.auth"]
  end

end
