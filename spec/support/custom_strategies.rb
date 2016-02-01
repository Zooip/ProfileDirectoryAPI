class JsonApiAttributesForStrategy
  def initialize
    @strategy = FactoryGirl.strategy_by_name(:attributes_for).new
  end

  # delegate :association, to: :@strategy

  def result(evaluation)
    {
      type: ActiveModel::Serializer.serializer_for(evaluation.object)._type,
      attributes:@strategy.result(evaluation)
    }
  end
end