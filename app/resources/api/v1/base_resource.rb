class Api::V1::BaseResource < JSONAPI::Resource

  abstract


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

end