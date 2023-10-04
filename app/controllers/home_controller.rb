class HomeController < ApplicationController

    def index
    end

    def apple_app_site_association
        render :json => {
            "applinks": {},
            "activitycontinuation": {},
            "webcredentials": {
                "apps": [
                    "org.aeroh.AerohLink"
                ]
            },
            "appclips": {}
        }
    end
end
