class Api::V1::BaseController < ApplicationController
  include Rails.application.routes.url_helpers

  @@oauth_scopes={}
  
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
      serializer_scope_hash={}
      serializer_scope_hash[:oauth_scopes]=current_oauth_scopes
      serializer_scope_hash[:oauth_ressource_owner]=current_user
      serializer_scope_hash[:oauth_application]=current_oauth_application
    end

    def verify_type(type)
      type_params=params.require(:data).require(:type)
      unless type_params == type.to_s
        return render status: :conflict,json: {
            errors:[
              { code: '409 Conflict',
                title: 'Wrong Resource type',
                detail: 'You didn\'t specified Resource type in your request body or this type is invalid with this end-point',
                meta:{
                  allowed_type: type.to_s
                }
               }]
            }
      end
    end

end
