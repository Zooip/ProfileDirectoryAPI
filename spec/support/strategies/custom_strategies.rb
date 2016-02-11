class JsonApiAttributesForStrategy
  def initialize
    @strategy = FactoryGirl.strategy_by_name(:attributes_for).new
  end

  # delegate :association, to: :@strategy

  def result(evaluation)
    {data:
      {
        type: JSONAPI::Resource.resource_for('api/v1/'+evaluation.object.class.model_name.element)._type,
        attributes:@strategy.result(evaluation)
      }
    }
  end
end