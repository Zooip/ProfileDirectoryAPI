class Gram::AccountAlias < Gram::Base
  belongs_to :account

  validates :account, presence: true
  validates :connection_alias, presence: true, uniqueness: true, format: { with: /\A([^\s]+)\z/i}


  def self.create_default_aliases_for user
    if user.soce_id
      user.account_aliases.create!(connection_alias: user.soce_id.to_s)
      user.account_aliases.create!(connection_alias: user.soce_id.to_s+("a".."z").to_a[(user.soce_id%23)].upcase)
    end
  end

end
