class ApplicationController < ActionController::Base
    include DeviseConcern

    before_action :set_devise_return_to_path
end
