# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  protect_from_forgery except: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    if ['application/vnd.api+json', 'application/json'].include? request.content_type
      if mobile_access_token_request_valid?
        @user = User.find_by(email: @email)
        if @user.present? and @user.valid_password?(@password)
          generate_mobile_access_token
        else
          render json: { errors: ["Email or Password is not valid!"], data: {} }, status: :unauthorized
          return false
        end
      end
    else
      if verify_authenticity_token != false
        super
      else
        raise ActionController::InvalidAuthenticityToken
      end
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
