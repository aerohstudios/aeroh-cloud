module Api::ApiHelper
    def authorize_api_endpoint
        unless user_signed_in?
            render json: {
                errors: [
                    status: 401,
                    title: "Unauthorized",
                    detail: "No valid user session or oauth access token found!"
                ]
            }, status: 401
        end
    end
end
