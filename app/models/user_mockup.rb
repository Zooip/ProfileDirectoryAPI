# UserMockup as a separation of concerns. Api-engine implementation should not impact MasterData database.
# This class is use as a placeholder for authentification logic and use password stored in MasterData database.
# 
## TODO
# Use external authentification if available (CAS)
#
class UserMockup < ActiveRecord::Base

  validates :profile_id, uniqueness: true, presence: true

  belongs_to :profile, class_name: 'MasterData::Profile'

  attr_accessor :password

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::Sha1 # Use SHA1 for compatibility reasons but should be changed when possible
    c.crypted_password_field=:encrypted_password
    c.require_password_confirmation=false
    c.validate_password_field=false
    c.check_passwords_against_database=false # UserMockup doesn't persist associated MasterDate::Profile encrypted_password
  end

  # Returns encrypted_password of associated Profile
  def encrypted_password
    profile.encrypted_password
  end

  # Find MasterData::Profile associated with this alias and return associated UserMockup or create it
  def self.find_by_connection_alias(value)
    MasterData::Profile.find_by_connection_alias(value).user_mockup || MasterData::Profile.find_by_connection_alias(value).create_user_mockup!
  end
end
