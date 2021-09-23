unless Object.const_defined?("JSONAPI::ResourceController")
    require 'jsonapi/resource_controller'
end

class ApplicationController < JSONAPI::ResourceController
    include DeviseConcern
    include Api::ApiHelper

    def context
        OpenStruct.new({current_user: current_user})
    end

    before_action :set_devise_return_to_path
end
