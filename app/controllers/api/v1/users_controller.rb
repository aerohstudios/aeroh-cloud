class Api::V1::UsersController < ApplicationController

    before_action :authorize_api_endpoint
    before_action -> { doorkeeper_authorize! :basic_info }, only: [:index]
end
