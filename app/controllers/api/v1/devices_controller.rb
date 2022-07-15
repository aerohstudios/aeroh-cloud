class Api::V1::DevicesController < ApplicationController

    before_action :authorize_api_endpoint
    skip_before_action :verify_authenticity_token, only: [:create, :destroy]
end
