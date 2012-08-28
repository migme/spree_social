class Spree::UserAuthentication < ActiveRecord::Base
  belongs_to :user

  attr_accessible :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

end
