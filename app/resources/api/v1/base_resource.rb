include ActiveSupport::Callbacks
class Api::V1::BaseResource < JSONAPI::Resource
  abstract
  set_callback :save, :before, :authorize
  


  define_callbacks :authorize
  # Authorize the model for the permission required by the controller
  # action. Also, mark the controller as having been policy authorized.
  def authorize
    run_callbacks :authorize do

      policy = Pundit.policy!(context.fetch(:current_token), @model)
      permission = "#{context.fetch(:current_action)}?"

      unless policy.public_send(permission)
        raise Pundit::NotAuthorizedError.new(query:permission, record: @model, policy: policy)
      end
    end
  end

  ##
  # Override default method to fetch all records
  # Use Pundit::Scopes to return only authorized records
  # 
  # Use ":context" defined in controller
  # Authorization is based on Doorkeeper access token
  #
  def self.records(_options = {})
    context=_options[:context] || {}
    Pundit.policy_scope(context[:current_token],_model_class) || _model_class
  end

  def records_for(association_name)
    record_or_records = @model.public_send(association_name)
    relationship = self.class._relationships[association_name]

    case relationship
      when JSONAPI::Relationship::ToOne
        record_or_records
      when JSONAPI::Relationship::ToMany
        ::Pundit.policy_scope!(context[:current_token], record_or_records)
      else
        raise "Unknown relationship type #{relationship.inspect}"
      end
  end

  def fetchable_fields
    super.to_a & Pundit.policy!(context.fetch(:current_token), @model).fetchable_fields.to_a
  end

end