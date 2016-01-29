class Api::V1::BaseController < ApplicationController
  
  include Rails.application.routes.url_helpers
  
  before_action :set_debug_headers
  serialization_scope :serializer_scope

  private

    def page_params
      raw=params.fetch(:page, {}).permit(:number, :size)
      {page:raw[:number],per_page:raw[:size]}
    end

    def filter_params
      params.fetch(:filter, {}).permit(filter_attributes << :id).transform_values { |v| v.to_s.split(',') }
    end

    def filter_attributes
      serializer = "MasterData::#{controller_name.titlecase.singularize.remove(' ')}Serializer"
      serializer.constantize._attributes
    end

    def fields_params
      fields=params.fetch(:fields,{}).transform_values { |v| v.to_s.split(',') }

    end

    def include_params
      fields=params.fetch(:include,'').split(',')
    end

    def set_debug_headers
      response.headers['X-Debug-Time'] = 'true'
    end

    def serializer_scope
       fields=params.fetch(:scope,{admin:false})
    end

end