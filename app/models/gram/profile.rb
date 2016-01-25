class Gram::Profile < Gram::Base
  belongs_to :account

  validates :account, presence: true
end
