module DeviseConcern

    def after_sign_in_path_for(resource)
        if session[:devise_return_to].present?
            return_to_path = session[:devise_return_to]
            session[:devise_return_to] = nil
            return_to_path
        else
            dashboard_index_path
        end
    end

    def set_devise_return_to_path
        if ["devise/registrations", "devise/sessions"].include? params["controller"] and
            params["action"] == "new" and
            params["return_to"].present?

            session[:devise_return_to] = params["return_to"]
        end
    end

    def mobile_access_token_request_valid?
        # check client id
        @oauth_app = Doorkeeper::Application.where(uid: params[:client_id]).first
        unless @oauth_app.present?
            render json: { errors: ["Request made from unknown application!"], data: {} }, status: :unauthorized
            return false
        end

        # check verify signature
        @email = params[:email].to_s
        @password = params[:password].to_s
        password_confirmation = params[:password_confirmation].to_s
        @first_name = params[:first_name].to_s
        @scopes = params[:scopes].to_s
        request_timestamp = params[:timestamp].to_i

        payload = {
            email: @email,
            password: @password
        }

        if params[:controller].ends_with? "registrations"
            payload[:password_confirmation] = password_confirmation
            payload[:first_name] = @first_name
        end

        payload[:scopes] = @scopes
        payload[:timestamp] = request_timestamp

        payload_json = payload.to_json
        Rails.logger.debug(payload_json)
        expected_signature = params[:signature].to_s
        actual_signature = generate_hmac(payload_json, @oauth_app.secret)

        if expected_signature != actual_signature
            render json: { errors: ["Request signature is invalid!"], data: {} }, status: :unauthorized
            return false
        end

        # check request timestamp is within last 5 seconds
        current_timestamp = Time.now.to_i

        if current_timestamp < request_timestamp or request_timestamp < current_timestamp - 5
            render json: { errors: ["Request timestamp is invalid! Server Time: #{current_timestamp}"], data: {} }, status: :unauthorized
            return false
        end

        # verify scope
        if @scopes != "mobile"
            render json: { errors: ["Request scope is invalid"], data: {} }, status: :unauthorized
            return false
        end

        if params[:controller].ends_with? "registrations"
            if @password != password_confirmation
                render json: { errors: ["Password and password confirmation do not match!"], data: {} }, status: :unauthorized
                return false
            end
        end

        return true
    end

    def generate_mobile_access_token
        access_token = Doorkeeper::AccessToken.create!(
            resource_owner_id: @user.id,
            application_id: @oauth_app.id,
            expires_in: Doorkeeper.configuration.access_token_expires_in,
            scopes: @scopes,
            use_refresh_token: true
        )

        render json: {
            data: {
                access_token: access_token.token,
                token_type: 'Bearer',
                refresh_token: access_token.refresh_token,
                expires_in: access_token.expires_in,
                created_at: access_token.created_at.to_i,
            }
        }
    end

    def generate_hmac(data, key)
        digest = OpenSSL::Digest.new('sha256')
        hmac = OpenSSL::HMAC.digest(digest, key, data)
        return hmac.unpack1('H*') # Returns hexadecimal representation
    end
end
