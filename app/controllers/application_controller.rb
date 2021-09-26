unless Object.const_defined?("JSONAPI::ResourceController")
    require 'jsonapi/resource_controller'
end

class ApplicationController < JSONAPI::ResourceController
    include DeviseConcern
    include Api::ApiHelper

    before_action :set_devise_return_to_path

    protected

    def context
        OpenStruct.new({current_user: current_resource_owner || current_user})
    end

    private

    def current_resource_owner
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
end
