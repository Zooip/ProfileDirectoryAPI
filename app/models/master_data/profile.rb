class MasterData::Profile < MasterData::Base

  ## ATTRIBUTES ###########################
  # id: integer
  # soce_id: integer
  # enable: boolean
  # encrypted_password: string
  # email: string
  # emergency_email: string
  # contact_phone: string
  # birth_date: date
  # death_date: date
  # first_name: string
  # last_name: string
  # birth_last_name: string
  # gender: string
  # login_validation_check: string
  # description: string
  # created_at: datetime
  # updated_at: datetime  
  attr_accessor :create_without_aliases
  attr_accessor :password


  ## RELATIONS ############################
  has_many :connection_aliases, dependent: :destroy
  has_one :user_mockup
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner

  ## VALIDATIONS ##########################  
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}
  validates :encrypted_password, presence: true
  validates :soce_id, presence: true, numericality: { only_integer: true }
  validates :gender, inclusion: {in: %w(male female)}, allow_nil: true

  ## CALLBACKS  ###########################  
  after_create :create_default_account_aliases, if: :with_aliases?
  before_save :sync_similar_attributes
  before_save :encrypt_password
  before_validation(:on => :create) do 
    if attribute_present?(:soce_id)
      set_soce_id_seq_value_to_max
    else
      self.soce_id = next_soce_id_seq_value
    end
  end



  after_initialize :set_init_values
  before_validation :set_default_values

  ## PUBLIC INSTANCE METHODS ##############
  def create_default_account_aliases
    MasterData::ConnectionAlias.create_default_aliases_for self
  end

  ## PUBLIC CLASS METHODS #################

  def self.find_by_connection_alias(value)
    MasterData::ConnectionAlias.find_by_connection_alias(value).profile
  end
  

  private
  ## PRIVATE INSTANCE METHODS #############
    ##
    #Define default values of runtime attributes
    def set_init_values
      self.create_without_aliases ||= false
    end

    def set_default_values
      self.emergency_email||= self.email
    end

    def sync_similar_attributes
      self.emergency_email= self.email if self.changes["email"] and (self.changes["email"][0] == self.emergency_email)
    end

    def with_aliases?
      !self.create_without_aliases
    end

    def next_soce_id_seq_value
      result = self.class.connection.execute("SELECT nextval('soce_id_seq')")
      result[0]['nextval']
    end

    def set_soce_id_seq_value_to_max
      self.class.connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT setval('soce_id_seq',(SELECT GREATEST((SELECT MAX(soce_id) FROM profiles),?)))",self.soce_id]))
    end

    def encrypt_password
      self.encrypted_password = UserMockup.crypto_provider.encrypt(self.password) if self.password
    end

  ## PRIVATE CLASS METHODS ################


end
