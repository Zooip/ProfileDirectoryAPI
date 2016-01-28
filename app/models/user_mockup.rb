class UserMockup < ActiveRecord::Base

  belongs_to :profile, class_name: 'Gram::Profile'

  attr_accessor :password

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::Sha1
    c.crypted_password_field=:encrypted_password
    c.require_password_confirmation=false
    c.validate_password_field=false
    c.check_passwords_against_database=false
  end

  def encrypted_password
    profile.encrypted_password
  end

  def self.find_by_connection_alias(value)
    Gram::Profile.find_by_connection_alias(value).user_mockup || Gram::Profile.find_by_connection_alias(value).create_user_mockup!
  end
end
