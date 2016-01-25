class Gram::Account < Gram::Base
  has_many :account_aliases
  after_create :create_default_account_aliases, if: :with_aliases?
  after_create :set_soce_id_seq_value_to_max
  before_validation(:on => :create) do 
    if attribute_present?(:soce_id)
      set_soce_id_seq_value_to_max
    else
      self.soce_id = next_soce_id_seq_value
    end
  end

  after_initialize :set_default_values

  attr_accessor :create_without_aliases

  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}
  validates :encrypted_password, presence: true
  validates :soce_id, presence: true, numericality: { only_integer: true }


  def create_default_account_aliases
    Gram::AccountAlias.create_default_aliases_for self
  end

  private
    ##
    #Define default values of runtime attributes
    def set_default_values
      self.create_without_aliases ||= false
    end


    def with_aliases?
      !self.create_without_aliases
    end

    def next_soce_id_seq_value
      # This returns a PGresult object [http://rubydoc.info/github/ged/ruby-pg/master/PGresult]
      result = Gram::Account.connection.execute("SELECT nextval('soce_id_seq')")

      result[0]['nextval']
    end

    def set_soce_id_seq_value_to_max
      result = Gram::Account.connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT setval('soce_id_seq',(SELECT GREATEST((SELECT MAX(soce_id) FROM accounts),?)))",self.soce_id]))
    end
end
