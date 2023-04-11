class Api::V1::DevicesController < ApplicationController

    before_action :authorize_api_endpoint
    skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy, :publish]

    before_action -> { doorkeeper_authorize! :read_devices }, only: [:index, :show]
    before_action -> { doorkeeper_authorize! :control_devices }, only: [:publish]
    before_action -> { doorkeeper_authorize! :write_devices }, only: [:create, :update, :destroy]

    def publish
        # extract params
        device_id = params.require(:id)
        data = params.require(:data)
        topic = data.require(:topic)
        payload = data[:payload].to_json

        # find device
        begin
            device = Device.find(device_id)
        rescue ActiveRecord::RecordNotFound => error
            render status: :not_found, json: {
                data: {},
                errors: [{
                    status: "404",
                    title: "Not Found",
                    details: error.to_s
                }]
            }
            return
        end

        # check if user has permission on the device
        unless device.can(current_user || current_resource_owner, :control)
            render status: unauthorized, json: {
                data: {},
                errors: [{
                    status: "401",
                    title: "Unauthorized",
                    detail: "User is not authorized to perform this action on the device!"
                }]
            }
            return
        end

        # publish message to mqtt broker
        # TODO: failed to send the command to the device
        endpoint_parameter = Aws::IoTDataPlane::EndpointParameters.new(region: 'us-east-1')
        endpoint_provider = Aws::IoTDataPlane::EndpointProvider.new.resolve_endpoint(endpoint_parameter)
        client = Aws::IoTDataPlane::Client.new(
            region: 'us-east-1',
            endpoint: endpoint_provider.url
        )
        client.publish(
            topic: "#{device.thing_arn.split("thing/").last}/#{topic}",
            payload: payload
        )

        render status: :created, json: {data: {}, errors: []}
    end
end
