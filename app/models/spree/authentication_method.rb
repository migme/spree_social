class Spree::AuthenticationMethod < ActiveRecord::Base
  attr_accessible :provider, :api_key, :api_secret, :environment, :active

  scope :current_env, where(:environment => ::Rails.env)

  class << self
    def get_auth(provider)
      current_env.where(:provider => provider).first
    end
  end


end
