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
        when login_user && login_user.activated?
          flash[:success] = "Signed in successfully."
          sign_in_and_redirect :user, login_user
        when login_user && !login_user.completed?
          flash[:success] = "Please continue your registration."
          session[:registering_user_id] = login_user.id
          redirect_to user_registration_next_step_path(login_user.state_name)
        else
          raise "#{login_user.id} - has error when try to authenticate with Facebook"
      end
    else
      if current_user
        current_user.completed_sign_up! if Spree::User::INCOMPLETE_STATES.include?(current_user.state_name)
        current_user.user_authentications.create!(:provider => auth_hash['provider'], :uid => auth_hash['uid'])
        flash[:success] = "Authentication successful."
        redirect_back_or_default(account_url)
      else
        # Register new account
        @user = Spree::User.new
        @user.apply_omniauth(auth_hash)
        @user.affiliate_code = session[:affiliate_code]
        if @user.save && @user.completed_sign_up!
          flash[:info] = "Your facebook account is already connected with our website. Please continue the registration."
          sign_in_and_redirect :user, @user
          #redirect_to redirect_back_or_default(account_url)
        else
          session[:omniauth] = auth_hash
          flash[:error] = "Your facebook account is already connected with our website. But we has problem when connect with your account, so please correct following information."
          redirect_to new_user_registration_url
        end
      end
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
