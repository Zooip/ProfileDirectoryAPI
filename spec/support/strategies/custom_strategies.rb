class JsonApiAttributesForStrategy
  def initialize
    @strategy = FactoryGirl.strategy_by_name(:attributes_for).new
  end

  # delegate :association, to: :@strategy

  def result(evaluation)
    {data:
      {
        type: ObjectSpace.each_object(Class).select { |klass| klass < JSONAPI::Resource }.detect{|x| x._model_name.to_s.constantize==evaluation.object.class}._type,
        attributes:@strategy.result(evaluation).select{|k,v| v}
      }
    }
  end
end