class Api::V2::BaseController < ApplicationController
  before_action :set_debug_headers

  private

    def page_params
      raw=params.fetch(:page, {}).permit(:number, :size)
      {page:raw[:number],per_page:raw[:size]}
    end

    def filter_params
      params.fetch(:filter, {}).permit(filter_attributes << :id).transform_values { |v| v.split(',') }
    end

    def filter_attributes
      serializer = "Gram::#{controller_name.titlecase.singularize}Serializer"
      serializer.constantize._attributes
    end

    def fields_params
      params.fetch(:fields,{}).permit(:gram_profiles).transform_values { |v| v.split(',') }
    end

    def set_debug_headers
      response.headers['X-Debug-Time'] = 'true'
    end

end