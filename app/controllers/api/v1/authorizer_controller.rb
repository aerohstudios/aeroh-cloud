class Api::V1::AuthorizerController < ApplicationController

    before_action :authorize_api_endpoint
    before_action -> { doorkeeper_authorize! :mobile, :control_devices }

    def index
        owner = current_resource_owner || current_user
        devices = params[:devices]
        authorized_devices_map = {}
        if devices
            device_list = devices.split(",").filter {|device| device.length > 0}
            authorized_devices = device_list.filter do |x|
                owner.devices.where("thing_arn LIKE ?", "%#{x}").count > 0
            end
            authorized_devices_map = Hash[device_list.map {|device| [device, authorized_devices.include?(device)] }]
        end
        render json: {authenticated: true, authorized: authorized_devices_map}
    end
end
