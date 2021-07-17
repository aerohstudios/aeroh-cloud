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
end
